import 'dart:io';

import 'package:flash_cards/src/data/model/study_card.dart';
import 'package:flash_cards/src/logic/file_downloader_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xml/xml.dart' as xml;
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;

class XmlHandler {
  static List<StudyCard> parseXml(String xmlString) {
    final document = xml.XmlDocument.parse(xmlString);
    final cards = document.findAllElements('card');

    List<StudyCard> parsedData = [];

    final deckName =
        document.findAllElements('deck').first.attributes.first.value;
    parsedData.add(StudyCard(front: deckName, back: cards.length.toString()));

    for (var card in cards) {
      final front = card
          .findElements('rich-text')
          .firstWhere((element) => element.getAttribute('name') == 'Front')
          .innerText;
      final back = card
          .findElements('rich-text')
          .firstWhere((element) => element.getAttribute('name') == 'Back')
          .innerText;
      parsedData.add(StudyCard(front: front, back: back));
    }

    return parsedData;
  }

  static String createXml(List<StudyCard> cards, String deckName) {
    final builder = xml.XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('deck', nest: () {
      builder.attribute('name', deckName);
      builder.element('cards', nest: () {
        for (var card in cards) {
          builder.element('card', nest: () {
            builder.element('rich-text', nest: () {
              builder.attribute('name', 'Front');
              builder.text(card.front);
              if (card.frontImage != '') {
                builder.element('media', nest: () {
                  builder.attribute('type', 'image');
                  builder.attribute('src',
                      '${card.id}_front.${card.frontImage.split('.').last}');
                });
              }
            });
            builder.element('rich-text', nest: () {
              builder.attribute('name', 'Back');
              builder.text(card.back);
              if (card.backImage != '') {
                builder.element('media', nest: () {
                  builder.attribute('type', 'image');
                  builder.attribute('src',
                      '${card.id}_back.${card.backImage.split('.').last}');
                });
              }
            });
          });
        }
      });
    });

    final document = builder.buildDocument();
    return document.toXmlString(pretty: true, indent: '  ');
  }

  static Future<void> saveXmlToFile(
      String xmlString, String fileName, Map<String, String> MediaMap) async {
    FileDownloaderHelper.saveFileOnDevice(fileName, xmlString, MediaMap);
  }

  static Future<void> unzipFile(File zipFile) async {
    try {
      // Verifica e richiesta dei permessi di archiviazione
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception("Permessi di archiviazione non concessi.");
      }

      // Ottieni la directory di archiviazione esterna
      Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir == null) {
        throw Exception(
            "Impossibile trovare la directory di archiviazione esterna.");
      }

      // Leggi il contenuto del file ZIP
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Ottieni il nome dell'archivio senza l'estensione .zip
      String zipFileName = path.basenameWithoutExtension(zipFile.path);

      // Crea la directory di destinazione con lo stesso nome dell'archivio
      Directory destinationDir =
          Directory(path.join(externalDir.path, zipFileName));
      await destinationDir.create(recursive: true);

      // Logging dettagliato
      print('Percorso della directory di destinazione: ${destinationDir.path}');
      print('Numero di file nell\'archivio ZIP: ${archive.length}');

      // Estrai ogni file dall'archivio ZIP nella directory di destinazione
      for (final file in archive) {
        if (file.isFile) {
          final filename = file.name;
          final filePath = path.join(destinationDir.path, filename);

          try {
            // Crea il file e scrivi il contenuto
            final outputFile = File(filePath);
            await outputFile.create(recursive: true);
            await outputFile.writeAsBytes(file.content as List<int>);
            print('File estratto: $filePath');
          } catch (e) {
            print('Errore durante l\'estrazione del file $filename: $e');
          }
        } else {
          // Se è una directory, crea la directory
          final dirPath = path.join(destinationDir.path, file.name);
          await Directory(dirPath).create(recursive: true);
          print('Directory creata: $dirPath');
        }
      }

      // Verifica se la directory contiene effettivamente dei file
      List<FileSystemEntity> contents = destinationDir.listSync();
      print('Contenuto della directory di destinazione: $contents');

      print('Unzipped successfully to ${destinationDir.path}');
    } catch (e) {
      print('Errore durante l\'unzip del file: $e');
    }
  }

  static Future<bool> requestStoragePermission() async {
    // Richiedi i permessi di archiviazione necessari
    if (Platform.isAndroid &&
        await Permission.manageExternalStorage.request().isGranted) {
      return true;
    } else if (await Permission.storage.request().isGranted) {
      return true;
    } else {
      return false;
    }
  }
}
