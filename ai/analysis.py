#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import numpy as np
import warnings

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
    """Mel-Spectrogram 변환"""
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

async def load_and_test_models(base_path):
    """모델 로딩 및 테스트 (MCIvsAD 모델만 사용)"""
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

        img_path = os.path.join(base_path, "voice-mels")

        # 테스트 실행
        check_file_json = await check_files(img_path, ".jpg")
        if not check_file_json["success"]:
            return check_file_json

        for model_name, model in loaded_models.items():
            mel_path = check_file_json["path"]
            try:
                # 이미지 전처리
                img = image.load_img(mel_path, target_size=(100, 100))
                img_array = image.img_to_array(img)
                img_array = np.expand_dims(img_array, axis=0)
                img_array /= 255.0

                # 예측 실행
                prediction = model.predict(img_array, verbose=0)[0][0]
                # 0~1 스코어
                score = float(prediction)

                """
                original_file = mel_file.replace('.jpg', '.wav')
                # 파일 타입 분석 (파일명에 OK / ALT 포함 여부로 판단)
                if 'OK' in original_file:
                    file_type = "정상 음성"
                    expected = "낮은 확률"
                elif 'ALT' in original_file:
                    file_type = "치매 의심 음성"
                    expected = "높은 확률"
                else:
                    file_type = "알 수 없음"
                    expected = "?"
                """

                # 위험도 범주화
                if score > 0.7:
                    risk_level = "높은 위험도"
                elif score > 0.4:
                    risk_level = "중간 위험도"
                else:
                    risk_level = "낮은 위험도"

                return {"success": True, "result": {"score": score, "risk_level": risk_level}}
            except Exception as e:
                return {"success": False, "message": f"{mel_path} 예측에 실패하였습니다: {e}"}

    except ImportError as e:
        return {"success": False, "message": f"필요한 라이브러리가 없습니다: {e}"}
    except Exception as e:
        return {"success": False, "message": f"모델 테스트에 실패하였습니다: {e}"}


async def main(base_path):
    """메인 함수"""

    mel_json = await convert_to_melspectrogram(base_path)
    if not mel_json["success"]:
        return mel_json

    # 2. 모델 테스트
    model_json = await load_and_test_models(base_path)

    if not model_json["success"]:
        return model_json

    # mel 이미지 경로 포함
    return {"success": True, "result": model_json["result"], "mel_path": mel_json.get("path")}
