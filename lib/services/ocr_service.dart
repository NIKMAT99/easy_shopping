import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  // Inizializza il riconoscitore per i caratteri latini
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<List<String>> processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      List<String> shoppingItems = [];

      // Analizza il testo riga per riga per isolare i singoli prodotti
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final text = line.text.trim();
          // Filtra eventuali righe vuote o artefatti troppo corti
          if (text.isNotEmpty && text.length > 1) {
            shoppingItems.add(text);
          }
        }
      }

      return shoppingItems;
    } catch (e) {
      print("Errore durante l'OCR: $e");
      return [];
    }
  }

  // È importante chiudere il riconoscitore per liberare memoria
  void dispose() {
    _textRecognizer.close();
  }
}