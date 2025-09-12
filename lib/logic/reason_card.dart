// // buildReasonCard(icon,intensity,contexts,evidence,top):
// // 예: “분노 8/10 + 직장·사람 + ‘빡치-’, ‘죽이-’ 단서 → 대인 갈등 분노/충동 패턴 → ‘감각 고정→재평가→10초 지연’ 120초 권장”

// String buildReasonCard({
//   required String icon,
//   required int intensity,
//   required List<String> contexts,
//   required List<String> evidence,
//   required String topCluster,
//   required String preset,
// }) {
//   final ctx = contexts.isEmpty ? '' : ' + ${contexts.join('·')}';
//   final ev = evidence.isEmpty ? '' : " + ‘${evidence.take(2).join('’, ‘')}’ 단서";
//   String presetKo = preset;
//   return "${_koCluster(icon)} $intensity/10$ctx$ev → ${_koCluster(topCluster)} 패턴 → ‘${_koPreset(preset)}’ 권장";
// }

// String _koCluster(String c) {
//   switch (c) {
//     case 'anxiety':
//       return '불안';
//     case 'depression':
//       return '우울';
//     case 'panic':
//       return '공포/패닉';
//     case 'anger':
//       return '분노/과민';
//     case 'numb':
//       return '무감각/공허';
//     case 'burnout':
//       return '피로/번아웃';
//     case 'recovery':
//       return '차분/안정';
//     default:
//       return c;
//   }
// }

// String _koPreset(String p) {
//   switch (p) {
//     case 'forest_reset':
//       return '숲 120초';
//     case 'bright_activate':
//       return '밝은 활성화 120초';
//     case 'ground_reframe':
//       return '그라운드·리프레임 120초';
//     case 'micro_refresh':
//       return '마이크로 리프레시 120초';
//     case 'focus_start':
//       return '집중 착수 120초';
//     default:
//       return p;
//   }
// }
