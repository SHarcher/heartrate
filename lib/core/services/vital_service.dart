import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../models/vital_result.dart';

/// VitalService
/// 封装对 Rouast VitalLens API 的调用
/// 每次上传一段视频到 https://api.rouast.com/vitals/video
/// 返回包含心率 (heart_rate) 与呼吸率 (respiratory_rate) 的结果
class VitalService {
  // ✅ 1. 创建 Dio 实例（HTTP 客户端）
  final Dio _dio = Dio();

  VitalService() {
    // ✅ 2. 设置默认 Header —— 在这里放你的 API Key
    _dio.options.headers['Authorization'] =
        'LBPmRL4NgW9g3ILex0cSt1k0rMpNwMEB4t0xXKcc'; // ←←← ←←← ⚠️ 在这修改 !!!
    _dio.options.baseUrl = vitalBaseUrl; // 来自 app_constants.dart
  }

  /// 上传视频文件到 VitalLens 进行分析
  /// [path] 是临时视频文件路径
  Future<VitalResult?> analyzeVideo(String path) async {
    try {
      // ✅ 3. 构建表单数据（包含视频文件）
      final form = FormData.fromMap({
        'video': await MultipartFile.fromFile(path),
      });

      // ✅ 4. 向 VitalLens API 发起 POST 请求
      final Response res = await _dio.post('/vitals/video', data: form);

      // ✅ 5. 从返回 JSON 提取心率与呼吸率数据
      final data = res.data['vital_signs'];
      final result = VitalResult.fromJson(data);

      print(
          '[VitalLens] 心率: ${result.heartRate} bpm, 呼吸率: ${result.respiration} rpm');
      return result;
    } catch (e) {
      print('[VitalLens] 调用失败: $e');
      return null;
    }
  }
}
