import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'regex_parser.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<ReceiptParseResult> processReceiptImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    final rawText = recognizedText.text;
    
    // Parse using heuristic regex engine
    return ReceiptRegexParser.parse(rawText);
  }

  void dispose() {
    _textRecognizer.close();
  }
}
