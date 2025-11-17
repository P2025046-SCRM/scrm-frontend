import 'constants.dart';

// Helper class for determining waste type labels from classification results
class WasteTypeHelper {
  // Determines the waste type label based on layer1 and layer2 classifications 
  // Returns a formatted string representing the waste type and recycling destination
  static String getWasteType(String layer1, String layer2) {
    String recycleType = '';
    if (layer1 == WasteTypes.noReciclable) {
      return 'No Reciclable';
    } else if (layer1 == WasteTypes.reciclable) {
      switch (layer2) {
        case WasteTypes.retazos:
          recycleType = 'Interno';
          break;
        case WasteTypes.biomasa:
          recycleType = 'Externo';
          break;
        case WasteTypes.metales:
          recycleType = 'Externo';
          break;
        case WasteTypes.plastico:
          recycleType = 'Interno';
          break;
        default:
          recycleType = 'Desconocido';
      }
      // Only return the recycle destination label (Interno/Externo/Desconocido)
      return recycleType;
    } else {
      return layer1;
    }
  }
}

