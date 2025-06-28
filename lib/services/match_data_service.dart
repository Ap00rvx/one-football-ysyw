import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ysyw/config/debug/debug.dart';
import 'package:ysyw/model/competetion_response_model.dart';

class MatchDataService {
  final apiUrl = dotenv.env['FOOTBALL_API_URL'];
  final apiKey = dotenv.env['FOOTBALL_API_KEY'];
  final headers = <String, String>{};
  final _dioClient = Dio(); 

  MatchDataService() {
    if (apiUrl == null) {
      throw Exception('API URL not found in environment variables');
    }
    if (apiUrl == null || apiKey == null) {
      throw Exception('API URL or API Key not found in environment variables');
    }
    headers['X-Auth-Token'] = apiKey!;
    headers['Content-Type'] = 'application/json';
    headers['Accept'] = 'application/json';
    _dioClient.options.baseUrl = apiUrl!;
    _dioClient.options.headers.addAll(headers);
    Debug.info('MatchDataService initialized with API URL: $apiUrl');
  }
  Future<Either<String, CompetetionsResponse>> getCompetitions() async {
    try {
      Debug.api('Fetching competitions from $apiUrl/competitions');
      Debug.info('Headers: $headers');
      final response = await _dioClient.get('/competitions');
      Debug.info('Response data: ${response.data}');
      if (response.statusCode == 200) {
        Debug.success('Competitions fetched successfully');
        return Right(CompetetionsResponse.fromJson(response.data));
      } else {
        Debug.error('Failed to fetch competitions: ${response.statusCode}');
        return Left('Failed to fetch competitions: ${response.statusCode}');
      }

    }on DioException catch (e) {
      Debug.error('DioException while fetching competitions: ${e.message}');

      if (e.response != null) {
        Debug.error('Response data: ${e.response?.data}');
        return Left('Error fetching competitions: ${e.response?.data}');
      } else {
        return Left('Error fetching competitions: ${e.message}');
      }
    } 
    catch (e) {
      Debug.error('Error fetching competitions: $e');
      return Left('Error fetching competitions: $e');
    }
  }
}
