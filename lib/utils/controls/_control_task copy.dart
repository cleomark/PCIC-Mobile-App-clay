import 'dart:io';
import 'package:csv/csv.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Task {
  final int id;
  late final bool isCompleted;
  final DateTime dateAdded;
  final DateTime dateAccess;
  final int ppirAssignmentId;
  final int ppirInsuranceId;
  Map<String, dynamic>? csvData;
  bool hasChanges = false;

  Task({
    required this.id,
    this.isCompleted = false,
    required this.dateAdded,
    required this.dateAccess,
    required this.ppirAssignmentId,
    required this.ppirInsuranceId,
    this.csvData,
  });

  Map<String, bool> getColumnStatus() {
    Map<String, bool> columnStatus = {};
    csvData?.forEach((key, value) {
      columnStatus[key] = value != null && value.toString().isNotEmpty;
    });
    return columnStatus;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      isCompleted: map['isCompleted'],
      dateAdded: _parseDate(map['dateAdded']),
      dateAccess: _parseDate(map['dateAccess']),
      ppirAssignmentId: map['ppir_assignmentid'],
      ppirInsuranceId: map['ppir_insuranceid'],
    );
  }

  static DateTime _parseDate(dynamic dateString) {
    if (dateString is String && dateString.length == 6) {
      try {
        final int month = int.parse(dateString.substring(0, 2));
        final int day = int.parse(dateString.substring(2, 4));
        final int year = int.parse(dateString.substring(4, 6)) + 2000;
        return DateTime(year, month, day);
      } catch (e) {
        debugPrint('Error parsing date: $e');
      }
    }
    // Return current date if parsing fails
    return DateTime.now();
  }

  static Future<List<Task>> getAllTasks() async {
    List<Task> tasks = [];

    try {
      // Load the original CSV data
      String csvData = await rootBundle
          .loadString('assets/storage/tasks/1706671193108371-1.csv');
      List<List<dynamic>> csvList = const CsvToListConverter().convert(csvData);

      // Create a map to store the CSV data with ppir_insuranceid as the key
      Map<String, Map<String, dynamic>> csvDataMap = {};
      for (List<dynamic> row in csvList) {
        String ppirInsuranceId = row[7].toString();
        csvDataMap[ppirInsuranceId] = {
          // ... (column mapping remains the same)
        };
      }

      DatabaseReference databaseReference =
          FirebaseDatabase.instance.ref().child('tasks');
      DatabaseEvent event = await databaseReference.once();
      DataSnapshot dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null) {
        if (dataSnapshot.value is Map<dynamic, dynamic>) {
          Map<dynamic, dynamic> values =
              dataSnapshot.value as Map<dynamic, dynamic>;
          values.forEach((key, value) {
            if (value is Map<dynamic, dynamic>) {
              Map<String, dynamic> taskData = Map<String, dynamic>.from(value);
              Task task = Task.fromMap(taskData);

              // Retrieve the CSV data for the task based on its ppirInsuranceId
              String ppirInsuranceId = task.ppirInsuranceId.toString();
              if (csvDataMap.containsKey(ppirInsuranceId)) {
                task.csvData = csvDataMap[ppirInsuranceId];
              }

              tasks.add(task);

              // Save the task data to a new CSV file named after the ppirInsuranceId
              task.saveCsvData();
            }
          });
        }
      }
    } catch (error) {
      debugPrint('Error retrieving tasks from Firebase: $error');
    }

    return tasks;
  }

  void updateCsvData(Map<String, dynamic> newData) {
    csvData ??= {};
    newData.forEach((key, value) {
      if (value.toString().isNotEmpty) {
        csvData![key] = value;
      }
    });
    hasChanges = true;
  }

  void updateColumnStatus(Map<String, bool> newColumnStatus) {
    csvData ??= {};
    newColumnStatus.forEach((key, value) {
      if (!value) {
        csvData![key] = '';
      }
    });
    hasChanges = true;
  }

  Future<void> saveCsvData() async {
    if (csvData != null) {
      try {
        final directory = await getExternalStorageDirectory();
        final csvFile = File('${directory!.path}/$ppirInsuranceId.csv');

        // Create the CSV file with the header row if it doesn't exist
        if (!await csvFile.exists()) {
          String headerRow =
              'Task Number,Service Group,Service Type,Priority,Task Status,Assignee,ppir_assignmentid,ppir_insuranceid,ppir_farmername,ppir_address,ppir_farmertype,ppir_mobileno,ppir_groupname,ppir_groupaddress,ppir_lendername,ppir_lenderaddress,ppir_cicno,ppir_farmloc,ppir_north,ppir_south,ppir_east,ppir_west,ppir_area_aci,ppir_area_act,ppir_dopds_aci,ppir_dopds_act,ppir_doptp_aci,ppir_doptp_act,ppir_svp_aci,ppir_svp_act,ppir_variety,ppir_stagecrop,ppir_remarks,ppir_name_insured,ppir_name_iuia,ppir_sig_insured,ppir_sig_iuia\n';
          await csvFile.writeAsString(headerRow);
        }

        // Create a list to store the CSV rows
        List<List<dynamic>> csvRows = [];

        // Add the data row
        List<dynamic> dataRow = List<dynamic>.filled(37, '');
        csvData!.forEach((key, value) {
          int columnIndex = _getColumnIndex(key);
          if (columnIndex != -1) {
            dataRow[columnIndex] = value;
          }
        });
        csvRows.add(dataRow);

        // Write the CSV rows to the file
        String csvContent = const ListToCsvConverter().convert(csvRows);
        await csvFile.writeAsString(csvContent, mode: FileMode.append);

        debugPrint('CSV file saved: ${csvFile.path}');
      } catch (error) {
        debugPrint('Error saving CSV data: $error');
      }
    }
  }

  int _getColumnIndex(String columnName) {
    // Define a map of column names to their respective indices
    Map<String, int> columnIndices = {
      'serviceGroup': 1,
      'serviceType': 2,
      'priority': 3,
      'taskStatus': 4,
      'assignee': 5,
      'ppirFarmerName': 8,
      'ppirAddress': 9,
      'ppirFarmerType': 10,
      'ppirMobileNo': 11,
      'ppirGroupName': 12,
      'ppirGroupAddress': 13,
      'ppirLenderName': 14,
      'ppirLenderAddress': 15,
      'ppirCicNo': 16,
      'ppirFarmLoc': 17,
      'ppirNorth': 18,
      'ppirSouth': 19,
      'ppirEast': 20,
      'ppirWest': 21,
      'ppirAreaAci': 22,
      'ppirAreaAct': 23,
      'ppirDopdsAci': 24,
      'ppirDopdsAct': 25,
      'ppirDoptpAci': 26,
      'ppirDoptpAct': 27,
      'ppirSvpAci': 28,
      'ppirSvpAct': 29,
      'ppirVariety': 30,
      'ppirStagecrop': 31,
      'ppirRemarks': 32,
      'ppirNameInsured': 33,
      'ppirNameIuia': 34,
      'ppirSigInsured': 35,
      'ppirSigIuia': 36,
    };
    return columnIndices[columnName] ?? -1;
  }

  Future<String> _getCsvFilePath() async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDirectory.path;
    String csvFilePath = '$appDocPath/1706671193108371-1.csv';

    // Check if the CSV file exists, and create it if it doesn't
    File csvFile = File(csvFilePath);
    if (!await csvFile.exists()) {
      // Create the CSV file with the header row
      String headerRow =
          'Task Number,Service Group,Service Type,Priority,Task Status,Assignee,ppir_assignmentid,ppir_insuranceid,ppir_farmername,ppir_address,ppir_farmertype,ppir_mobileno,ppir_groupname,ppir_groupaddress,ppir_lendername,ppir_lenderaddress,ppir_cicno,ppir_farmloc,ppir_north,ppir_south,ppir_east,ppir_west,ppir_area_aci,ppir_area_act,ppir_dopds_aci,ppir_dopds_act,ppir_doptp_aci,ppir_doptp_act,ppir_svp_aci,ppir_svp_act,ppir_variety,ppir_stagecrop,ppir_remarks,ppir_name_insured,ppir_name_iuia,ppir_sig_insured,ppir_sig_iuia\n';
      await csvFile.writeAsString(headerRow);
    }

    debugPrint(csvFilePath);

    return csvFilePath;
  }
}