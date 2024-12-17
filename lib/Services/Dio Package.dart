import 'package:dio/dio.dart';

class DioHelper{
  static late Dio dio;
  static init()
  {
    dio = Dio(
        BaseOptions(
            baseUrl: 'https://fakestoreapi.com/',
            receiveDataWhenStatusError: true,
            headers: {
              'Content-Type':'application/json',
              'lang':'en'
            }
        )
    );
  }
  static Future<Response> getData({required String url,
    Map<String,dynamic>? query,
    String lang='en',
    String token=''
  })async
  {
    dio.options.headers =
    {
      'lang':lang,
      'Content-Type':'application/json'
    };
    print('url is $url');
    return await dio.get(url,queryParameters: query);
  }
  static Future<Response> postData({required String url,
    Map<String,dynamic>? query,
    required Map<String,dynamic> data,
    String lang='en',
    String token=''
  })async
  {
    dio.options.headers =
    {
      'lang':lang,
      'Content-Type':'application/json'
    };
    return await dio.post(url,queryParameters: query,data: data);
  }
}