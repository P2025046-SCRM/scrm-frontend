// Helper class for determining waste type labels from classification results
class WasteTypeHelper {
  // Determines the waste type label based on layer1 and layer2 classifications 
  // Returns a formatted string representing the waste type and recycling destination
  static String getWasteType(String layer1, String layer2) {
    String recycleType = '';
    if (layer1 == 'NoReciclable') {
      return 'No Reciclable';
    } else if (layer1 == 'Reciclable') {
      switch (layer2) {
        case 'Retazos':
          recycleType = 'Interno';
          break;
        case 'Biomasa':
          recycleType = 'Externo';
          break;
        case 'Metales':
          recycleType = 'Externo';
          break;
        case 'Plastico':
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

