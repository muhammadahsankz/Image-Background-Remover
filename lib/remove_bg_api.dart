import 'package:http/http.dart';

class RemoveBgApi {
  static const apiKey = 'L9GQJsfTLCagUcRWwiHvuR2P';
  static var baseUrl = Uri.parse('https://api.remove.bg/v1.0/removebg');

  static removebg(String imagePath) async {
    try {
      var req = MultipartRequest('POST', baseUrl);
      req.headers.addAll({'X-API-KEY': apiKey});
      req.files.add(await MultipartFile.fromPath('image_file', imagePath));
      final response = await req.send();
      if (response.statusCode == 200) {
        Response image = await Response.fromStream(response);
        return image.bodyBytes;
      } else {
        print('failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
