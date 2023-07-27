//It receives a string and returns N terms based on frequency.
//The terms can be one or two words and it will pick the two words if in threshold
import 'dart:math';

List<String> recommendedStrings(String text) {
  int topN = 12; //number of results returned
  double threshold =
      0.15; //it will remove the single word result if the double word that contain it its on the threshold
  //articles and other to remove from the results
  List<String> articles = [
    'a',
    'an',
    'the',
    'o',
    'para',
    'um',
    'vi',
    'ao',
    'e',
    'do',
    'de',
    'da',
    'no',
    "-",
    "0",
    "- 0"
  ];
  text = text.replaceAll(',', '').replaceAll('.', '').replaceAll("  ", " ");

  List<String> words = text.split(' ');

  Map<String, int> frequencyMap = {};

  for (int i = 0; i < words.length - 1; i++) {
    String word1 = words[i];
    String word2 = words[i + 1];

    if (frequencyMap.containsKey(word1)) {
      frequencyMap[word1] = frequencyMap[word1]! + 1;
    } else {
      frequencyMap[word1] = 1;
    }
    // Combine the current word and the next word to create a two-word term
    String twoWordTerm = '$word1 $word2';

    // Update the frequency map for two-word terms
    if (frequencyMap.containsKey(twoWordTerm)) {
      frequencyMap[twoWordTerm] = frequencyMap[twoWordTerm]! + 1;
    } else {
      frequencyMap[twoWordTerm] = 1;
    }
  }

// Remove two-word terms that don't have corresponding single words
  frequencyMap.removeWhere((key, value) {
    List<String> words = key.split(' ');
    if (words.length == 2 &&
        (frequencyMap[words[0]] == null || frequencyMap[words[1]] == null)) {
      return true;
    }
    return false;
  });

  List<MapEntry<String, int>> sortedEntries = frequencyMap.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  List<String> topWordsOrTerms = [];

  for (int i = 0; i < sortedEntries.length; i++) {
    String entry = sortedEntries[i].key;
    int frequency = sortedEntries[i].value;
    bool isOneWord = entry.contains(' ');

    if (isOneWord) {
      String correspondingTwoWordTerm =
          entry.split(' ').join(''); // Remove spaces from the one-word entry
      bool hasSimilarFrequency = false;
      for (int j = i + 1; j < sortedEntries.length; j++) {
        String otherEntry = sortedEntries[j].key;
        int otherFrequency = sortedEntries[j].value;

        if (otherEntry == correspondingTwoWordTerm &&
            (otherFrequency - frequency).abs() <= threshold * frequency) {
          hasSimilarFrequency = true;
          break;
        }
      }
      if (hasSimilarFrequency) continue;
    }

    // Exclude articles
    if (articles.contains(entry.toLowerCase())) continue;
    topWordsOrTerms.add(entry);
    if (topWordsOrTerms.length >= topN) break;
  }
  return topWordsOrTerms;
}

//First letter to Uppercase
String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String getRandomString(int len) {
  var r = Random();
  const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
}

bool objectExist(String registration, T) {
  for (var object in T) {
    if (object.registration == registration) {
      return true;
    }
  }
  return false;
}
