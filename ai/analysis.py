#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import numpy as np
import warnings
from typing import List, Tuple, Dict, Any, Optional

warnings.filterwarnings('ignore')  # 경고 메시지 무시 설정

# 폴더, 파일 존재 여부 확인
async def check_files(base_path, file_type):

    """파일 확인"""
    if not os.path.exists(base_path):
        return {"success": False, "message": f"존재하지 않는 위치입니다: {base_path}"}

    file_path = None
    for file_name in os.listdir(base_path):
        if file_name.endswith(file_type):
            file_path = os.path.join(base_path, file_name)
            # file_size = os.path.getsize(file_path) / 1024  # KB 단위
            break

    if file_path == None:
        return {"success": False, "message": f"해당 폴더에서 {file_type} 타입의 파일을 찾을 수 없습니다: {base_path}"}

    return {"success": True, "path": file_path}


async def convert_to_melspectrogram(base_path):
    """Mel-Spectrogram 변환 (단일 파일)"""
    try:
        import librosa
        import librosa.display  # ensure display submodule is available
        import matplotlib
        matplotlib.use('Agg')  # 화면 출력없이 파일 저장 가능하게 설정
        import matplotlib.pyplot as plt

        output_dir = os.path.join(base_path, "voice-mels")
        os.makedirs(output_dir, exist_ok=True)

        check_file_json = await check_files(base_path, ".wav")
        if not check_file_json["success"]:
            import shutil
            shutil.rmtree(base_path)
            return check_file_json

        wav_path = check_file_json["path"]
        try:

            y, sr = librosa.load(wav_path, sr=22050)  # 지정 샘플레이트로 로드

            # Mel-Spectrogram 생성
            S = librosa.feature.melspectrogram(y=y, sr=sr, n_mels=128)
            S_db = librosa.power_to_db(S, ref=np.max)

            # 이미지로 저장
            plt.figure(figsize=(1, 1))
            librosa.display.specshow(S_db, sr=sr)
            plt.axis('off')
            plt.tight_layout()

            mel_filename = os.path.split(wav_path)[1].replace('.wav', '.jpg')
            mel_path = os.path.join(output_dir, mel_filename)
            plt.savefig(mel_path, bbox_inches='tight', pad_inches=0, dpi=100)
            plt.close()

        except Exception as e:
            return {"success": False, "message": f"Mel-Spectrogram 변환에 실패하였습니다: {e}"}

        return {"success": True, "path": mel_path}

    except ImportError as e:
        return {"success": False, "message": f"필요한 라이브러리가 없습니다: {e}"}

    except Exception as e:
        return {"success": False, "message": f"Mel-Spectrogram 변환에 실패하였습니다: {e}"}

async def convert_all_to_melspectrograms(base_path: str) -> Dict[str, Any]:
    """
    base_path 내의 모든 .wav 파일에 대해 mel-spectrogram 이미지를 생성합니다.
    결과는 base_path/voice-mels/*.jpg 로 저장하며, 생성된 이미지 경로 목록을 반환합니다.
    """
    try:
        import librosa
        import librosa.display
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt

        output_dir = os.path.join(base_path, "voice-mels")
        os.makedirs(output_dir, exist_ok=True)

        wav_files = [f for f in os.listdir(base_path) if f.lower().endswith('.wav')]
        if not wav_files:
            return {"success": False, "message": f"해당 폴더에 .wav 파일이 없습니다: {base_path}"}

        mel_paths: List[str] = []
        for fname in wav_files:
            wav_path = os.path.join(base_path, fname)
            try:
                y, sr = librosa.load(wav_path, sr=22050)
                S = librosa.feature.melspectrogram(y=y, sr=sr, n_mels=128)
                S_db = librosa.power_to_db(S, ref=np.max)
                plt.figure(figsize=(1, 1))
                librosa.display.specshow(S_db, sr=sr)
                plt.axis('off')
                plt.tight_layout()
                mel_filename = os.path.splitext(fname)[0] + '.jpg'
                mel_path = os.path.join(output_dir, mel_filename)
                plt.savefig(mel_path, bbox_inches='tight', pad_inches=0, dpi=100)
                plt.close()
                mel_paths.append(mel_path)
            except Exception as e:
                # 개별 파일 실패 시 다음 파일 진행
                continue
        if not mel_paths:
            return {"success": False, "message": "Mel-Spectrogram 생성에 모두 실패했습니다."}
        return {"success": True, "paths": mel_paths}
    except ImportError as e:
        return {"success": False, "message": f"필요한 라이브러리가 없습니다: {e}"}
    except Exception as e:
        return {"success": False, "message": f"Mel-Spectrogram 일괄 변환 중 오류: {e}"}

async def load_and_test_models(base_path, mel_paths: Optional[List[str]] = None):
    """모델 로딩 및 테스트 (MCIvsAD 모델만 사용, 다중 이미지 지원)"""
    try:
        import tensorflow as tf
        from tensorflow.keras.applications import VGG16
        from tensorflow.keras import models, layers
        from tensorflow.keras.preprocessing import image
        import h5py

        # 모델 로딩 설정 (환경변수로 경로 지정 가능)
        mci_model_path = os.getenv('MCI_MODEL_PATH', 'models/MCIvsADModel_68.7.h5')
        model_paths = [
            ('MCIvsAD', mci_model_path),
        ]
        loaded_models = {}

        for model_name, model_path in model_paths:
            if not os.path.exists(model_path):
                continue

            try:
                # VGG16 기반 모델 구조 생성
                base_model = VGG16(weights='imagenet', include_top=False, input_shape=(100, 100, 3))
                model = models.Sequential([
                    base_model,
                    layers.Flatten(name='flatten'),
                    layers.Dense(10, activation='relu'),
                    layers.Dense(1, activation='sigmoid')
                ])
                model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

                # 가중치 직접 로드 (h5py를 통해)
                try:
                    with h5py.File(model_path, 'r') as f:
                        dense_weights = f['model_weights/dense/dense/kernel:0'][:]
                        dense_bias = f['model_weights/dense/dense/bias:0'][:]
                        dense_1_weights = f['model_weights/dense_1/dense_1/kernel:0'][:]
                        dense_1_bias = f['model_weights/dense_1/dense_1/bias:0'][:]

                        model.layers[2].set_weights([dense_weights, dense_bias])
                        model.layers[3].set_weights([dense_1_weights, dense_1_bias])

                        loaded_models[model_name] = model

                except Exception as e:
                    # 가중치 로딩 실패, 기본 모델 사용
                    loaded_models[model_name] = model

            except Exception as e:
                # 모델 로딩 실패
                return {"success": False, "message": f"모델을 로드하던 중 에러가 발생하였습니다: {e}"}

        if not loaded_models:
            return {"success": False, "message": "모델을 로드하는 데 실패하였습니다."}

        img_dir = os.path.join(base_path, "voice-mels")
        if not mel_paths:
            # 수집
            mel_paths = [
                os.path.join(img_dir, f)
                for f in os.listdir(img_dir)
                if f.lower().endswith('.jpg')
            ]
        if not mel_paths:
            return {"success": False, "message": "분석할 이미지(멜스펙트로그램)가 없습니다."}

        scores: List[Tuple[str, float]] = []
        for model_name, model in loaded_models.items():
            for mel_path in mel_paths:
                try:
                    # 이미지 전처리
                    img = image.load_img(mel_path, target_size=(100, 100))
                    img_array = image.img_to_array(img)
                    img_array = np.expand_dims(img_array, axis=0)
                    img_array /= 255.0

                    # 예측 실행
                    prediction = model.predict(img_array, verbose=0)[0][0]
                    score = float(prediction)
                    scores.append((mel_path, score))
                except Exception as e:
                    continue

        if not scores:
            return {"success": False, "message": "모델 예측에 실패했습니다."}

        # 평균 점수 계산 및 리스크 레벨
        avg_score = float(np.mean([s for _, s in scores]))
        if avg_score > 0.7:
            risk_level = "높은 위험도"
        elif avg_score > 0.4:
            risk_level = "중간 위험도"
        else:
            risk_level = "낮은 위험도"

        return {
            "success": True,
            "result": {
                "score": avg_score,
                "risk_level": risk_level,
                "details": [{"mel_path": p, "score": s} for p, s in scores]
            }
        }

    except ImportError as e:
        return {"success": False, "message": f"필요한 라이브러리가 없습니다: {e}"}
    except Exception as e:
        return {"success": False, "message": f"모델 테스트에 실패하였습니다: {e}"}


async def main(base_path, mel_pick: Optional[str] = None):
    """메인 함수"""

    # 1. 멜스펙트로그램 생성(다중 파일)
    mel_all_json = await convert_all_to_melspectrograms(base_path)
    if not mel_all_json.get("success"):
        return mel_all_json
    mel_paths: List[str] = mel_all_json.get("paths", [])

    # 2. 모델 테스트 (여러 이미지 대상)
    model_json = await load_and_test_models(base_path, mel_paths)

    if not model_json["success"]:
        return model_json

    # mel 이미지 선택 로직
    selected_mel = None
    details = (model_json.get("result") or {}).get("details") or []
    if details:
        if mel_pick is None or mel_pick == "max":
            # 최고 점수의 mel 선택
            selected_mel = max(details, key=lambda d: d.get("score", 0)).get("mel_path")
        elif mel_pick == "first":
            selected_mel = details[0].get("mel_path")
        elif mel_pick == "last":
            selected_mel = details[-1].get("mel_path")
        else:
            # 숫자 인덱스 시도
            try:
                idx = int(mel_pick)
                if 0 <= idx < len(details):
                    selected_mel = details[idx].get("mel_path")
                else:
                    selected_mel = details[0].get("mel_path")
            except Exception:
                selected_mel = details[0].get("mel_path")

    return {"success": True, "result": model_json["result"], "mel_path": selected_mel}
