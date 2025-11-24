import 'package:flutter/material.dart';
import 'package:memorion_caregiver/components/tag.dart';

class ValueName {
  static const String userName = "username";
  static const String fontSize = "fontsize";
  static const String isConnection = "is_connection";
  static const String guardianName = "guardian_name";
  static const String callTime = "call_time";
  static const String callTry = "call_try";
  static const String dark = "dark";
  static const String language = "language";
  static const String languageList = "language_list";
  static const String version = "version";
}

final Map<int, String> statusText = {
  -1: "아직 전화 기록이 없어요.",
   1: "오늘을 기록했어요.",
   2: "주의가 필요해요.",
   3: "치매 증상이 의심돼요.",
};

final Map<int, Widget> statusTag = {
  -1: settingTag(),
   1: greenTag(),
   2: orangeTag(),
   3: redTag(),
};

final Map<int, String> statusInfoText = {
  -1: """
아직 전화 기록이 없어요.
피보호자님과의 통화 기록이 존재하지 않아 분석을 진행할 수 없었어요.
먼저 통화를 한 번 진행해주시면, 목소리 변화나 대화 패턴 등을 기반으로 건강 상태를 분석해드릴 수 있어요.
""",

  1: """
오늘을 기록했어요.
오늘 피보호자님과의 통화가 정상적으로 기록되었어요.
현재로서는 우려되는 변화는 보이지 않지만, 꾸준한 모니터링을 통해 건강 상태를 안정적으로 관리할 수 있어요.
""",

  2: """
주의가 필요해요.
오늘의 통화 분석 결과, 이전과 비교했을 때 약간의 변화가 감지되었어요.
목소리 떨림이나 말 속도의 변화 등이 발견될 수 있으며, 일시적인 컨디션 변화일 수도 있지만, 며칠간 상태를 지켜보는 것이 좋아요.
만약 유사한 패턴이 반복된다면 병원 상담을 고려해보는 것이 좋습니다.
""",

  3: """
치매 증상이 의심돼요.
피보호자님과 대화를 나누는 동안 목소리가 어눌하거나 부자연스러운 부분이 감지되었어요.
추가적으로 진단 설문 결과에서도 위험 신호가 확인되어 치매가 강하게 의심되는 상태예요.
정확한 판단을 위해 가까운 병원이나 전문 클리닉에서 검사를 받아보시길 권해드려요.
""",
};
