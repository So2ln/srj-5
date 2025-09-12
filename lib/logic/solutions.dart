// // mapSolution(topCluster):
// // anxiety/panic → ‘forest_reset’, [‘시선 재배치 30s’, ‘리프레이밍 1문장’, ‘핑크/브라운 노이즈’]
// // depression → ‘bright_activate’, [‘밝은 시각’, ‘행동 1-step’, ‘자기칭찬’]
// // anger → ‘ground_reframe’, [‘5-4-3-2-1’, ‘재평가 2문장’, ‘10초 지연’]
// // burnout → ‘micro_refresh’, [‘미세 스트레칭’, ‘소음 전환’, ‘착수 프롬프트’]
// // recovery → ‘focus_start’, [‘착수 프롬프트’, ‘20분 타이머’, ‘성취 체크’]

// class SolutionPreset {
//   static Map<String, List<String>> get steps => {
//     'forest_reset': ['시선 재배치 30초', '리프레이밍 1문장', '핑크/브라운 노이즈 30초'],
//     'bright_activate': ['밝은 시각 30초', '행동 1-step 60초', '자기칭찬 30초'],
//     'ground_reframe': ['5-4-3-2-1 감각 고정 45초', '재평가 2문장 45초', '10초 지연+대안 30초'],
//     'micro_refresh': ['미세 스트레칭 60초', '소음 스펙트럼 전환 30초', '착수 프롬프트 30초'],
//     'focus_start': ['착수 프롬프트', '20분 타이머', '성취 체크'],
//   };
// }

// Map<String, String> presetName = {
//   'forest_reset': '숲 120초',
//   'bright_activate': '밝은 활성화 120초',
//   'ground_reframe': '그라운드·리프레임 120초',
//   'micro_refresh': '마이크로 리프레시 120초',
//   'focus_start': '집중 착수 120초',
// };

// String pickPreset(String topCluster) {
//   switch (topCluster) {
//     case 'anxiety':
//     case 'panic':
//       return 'forest_reset';
//     case 'depression':
//       return 'bright_activate';
//     case 'anger':
//       return 'ground_reframe';
//     case 'burnout':
//       return 'micro_refresh';
//     case 'recovery':
//       return 'focus_start';
//     default:
//       return 'forest_reset';
//   }
// }
