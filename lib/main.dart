import 'dart:io';

import 'package:ali_tools/report.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xcel;

import 'package:intl/intl.dart' as intl;

String dbName = 'reportDB';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ReportAdapter());
  await Hive.openBox<Report>(dbName);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Ali Tools'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            // save all reports to excel file
            return [
              PopupMenuItem(
                  child: ListTile(
                      leading: const Icon(Icons.file_download_outlined),
                      title: const Text('Download All Reports'),
                      onTap: () async {
                        final Box<Report> box = Hive.box<Report>(dbName);
                        final xcel.Workbook workbook = xcel.Workbook();
                        final xcel.Worksheet sheet = workbook.worksheets[0];
                        sheet.getRangeByName('A1').setText('Company Name');
                        sheet.getRangeByName('B1').setText('Equipment Name');
                        sheet.getRangeByName('C1').setText('Modal');
                        sheet.getRangeByName('D1').setText('Serial Number');
                        sheet.getRangeByName('E1').setText('ID');
                        sheet.getRangeByName('F1').setText('Year');
                        sheet.getRangeByName('G1').setText('Last TUV');
                        sheet.getRangeByName('H1').setText('Capacity');
                        sheet.getRangeByName('I1').setText('Type Inspection');
                        sheet.getRangeByName('J1').setText('TimeSheet');
                        sheet.getRangeByName('L1').setText('Result');
                        sheet.getRangeByName('M1').setText('Location');
                        sheet.getRangeByName('N1').setText('Comments');
                        sheet.getRangeByName('O1').setText('Validation');
                        sheet.getRangeByName('P1').setText('Sticker Number');
                        sheet.getRangeByName('K1').setText('Date of Submit');

                        for (int i = 0; i < box.length; i++) {
                          final Report report = box.getAt(i)!;
                          sheet
                              .getRangeByName('A${i + 2}')
                              .setText(report.companyName);
                          sheet
                              .getRangeByName('B${i + 2}')
                              .setText(report.equipmentName);
                          sheet
                              .getRangeByName('C${i + 2}')
                              .setText(report.modal);
                          sheet
                              .getRangeByName('D${i + 2}')
                              .setText(report.serialNumber);
                          sheet.getRangeByName('E${i + 2}').setText(report.id);
                          sheet
                              .getRangeByName('F${i + 2}')
                              .setText(report.year);
                          sheet
                              .getRangeByName('G${i + 2}')
                              .setText(report.lastTUV);
                          sheet
                              .getRangeByName('H${i + 2}')
                              .setText(report.capcity);
                          sheet
                              .getRangeByName('I${i + 2}')
                              .setText(report.typeInspection);
                          sheet
                              .getRangeByName('J${i + 2}')
                              .setText("TS-${report.timeSheet}");
                          sheet
                              .getRangeByName('L${i + 2}')
                              .setText(report.result ?? 'Not Available');
                          sheet
                              .getRangeByName('M${i + 2}')
                              .setText(report.location);
                          sheet
                              .getRangeByName('N${i + 2}')
                              .setText(report.comments);
                          sheet
                              .getRangeByName('O${i + 2}')
                              .setText(report.validation ?? 'Not Available');
                          sheet
                              .getRangeByName('P${i + 2}')
                              .setText(report.stickerNumber ?? 'Not Available');
                          sheet.getRangeByName('K${i + 2}').setText(
                              intl.DateFormat('dd/MM/yyyy')
                                  .format(report.dateOfSubmit!));
                        }
                        // save file
                        final List<int> bytes = workbook.saveAsStream();
                        if (Platform.isAndroid) {
                          final directory =
                              await FilePicker.platform.getDirectoryPath();
                          final File file = File('$directory/all_reports.xlsx');
                          file.writeAsBytes(bytes);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('File saved successfully')));
                        } else if (Platform.isWindows ||
                            Platform.isLinux ||
                            Platform.isMacOS) {
                          String? result = await FilePicker.platform.saveFile(
                            dialogTitle: 'Save the file',
                            fileName: 'all_reports.xlsx',
                            type: FileType.custom,
                            allowedExtensions: ['xlsx'],
                          );
                          // choose where to save the file
                          if (result != null) {
                            final File file = File(result);
                            file.writeAsBytes(bytes);
                          }
                        }
                      }))
            ];
          })
        ],
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Report>(dbName).listenable(),
        builder: (BuildContext context, Box<Report> box, Widget? child) {
          if (box.isEmpty) {
            return const Center(
                child: Text(
              'No data',
              style: TextStyle(fontSize: 30),
            ));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (BuildContext context, int index) {
              final Report report = box.getAt(index)!;
              return ListTile(
                trailing: report.result == 'Pass'
                    ? const Icon(Icons.check_circle_outline,
                        color: Colors.green)
                    : const Icon(Icons.cancel_outlined, color: Colors.red),
                leading: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            icon: const Icon(Icons.warning_amber_outlined),
                            title: Text('Delete ${report.companyName} report'),
                            content: const Text('Are you sure?'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('NO')),
                              OutlinedButton(
                                  onPressed: () {
                                    // delete from hive
                                    box.deleteAt(index);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('YES')),
                            ],
                          );
                        });
                  },
                ),
                onLongPress: () {
                  // show edit page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterPage(
                                index: index,
                                report: report,
                              )));
                },
                onTap: () {
                  // navigate to detail page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DetailsPage(report: report, index: index)));
                },
                title: Text(report.companyName),
                subtitle: Text(report.equipmentName),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const RegisterPage()));
        },
        tooltip: 'Add Report',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DetailsPage extends StatefulWidget {
  final int? index;
  final Report report;
  const DetailsPage({super.key, required this.report, this.index});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Details'),
          centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Company Name",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(widget.report.companyName,
                        style: const TextStyle(fontSize: 15)),
                  ],
                ),
                (widget.report.result == 'Pass')
                    ? const Icon(Icons.check_circle_outline,
                        size: 60, color: Colors.green)
                    : const Icon(Icons.cancel_outlined,
                        size: 60, color: Colors.red),
              ],
            ),
            const SizedBox(height: 10),
            const Text("Location",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.report.location, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            const Text("Equipment Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.report.equipmentName,
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            const Text("Modal",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.report.modal, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            const Text("Serial Number",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.report.serialNumber,
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            const Text("ID",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.report.id, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            const Text("Year",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.report.year, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            const Text("Last TUV",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.report.lastTUV, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            const Text("Capacity",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.report.capcity, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            const Text("Type Inspection",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.report.typeInspection,
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            const Text("TimeSheet",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text("TS-${widget.report.timeSheet}",
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            const Text("Result",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.report.result ?? 'Not Available',
                style: TextStyle(
                    color: widget.report.result == 'Pass'
                        ? Colors.green
                        : Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text("Comments",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.report.comments, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            const Text("Validation",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.report.validation ?? 'Not Available',
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            const Text("Sticker Number",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.report.stickerNumber ?? 'Not Available',
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            RichText(
                text: TextSpan(
                    style: const TextStyle(color: Colors.blue),
                    children: [
                  const TextSpan(text: 'Date of Submit: '),
                  TextSpan(
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      text: intl.DateFormat('dd/MM/yyyy')
                          .format(widget.report.dateOfSubmit!))
                ]))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Download Excel File",
        child: const Icon(Icons.file_download_outlined),
        onPressed: () async {
          final xcel.Workbook workbook = xcel.Workbook();
          final xcel.Worksheet sheet = workbook.worksheets[0];
          sheet.getRangeByName('A1').setText('Company Name');
          sheet.getRangeByName('B1').setText('Equipment Name');
          sheet.getRangeByName('C1').setText('Modal');
          sheet.getRangeByName('D1').setText('Serial Number');
          sheet.getRangeByName('E1').setText('ID');
          sheet.getRangeByName('F1').setText('Year');
          sheet.getRangeByName('G1').setText('Last TUV');
          sheet.getRangeByName('H1').setText('Capacity');
          sheet.getRangeByName('I1').setText('Type Inspection');
          sheet.getRangeByName('J1').setText('TimeSheet');
          sheet.getRangeByName('L1').setText('Result');
          sheet.getRangeByName('M1').setText('Location');
          sheet.getRangeByName('N1').setText('Comments');
          sheet.getRangeByName('O1').setText('Validation');
          sheet.getRangeByName('P1').setText('Sticker Number');
          sheet.getRangeByName('K1').setText('Date of Submit');

          sheet.getRangeByName('A2').setText(widget.report.companyName);
          sheet.getRangeByName('B2').setText(widget.report.equipmentName);
          sheet.getRangeByName('C2').setText(widget.report.modal);
          sheet.getRangeByName('D2').setText(widget.report.serialNumber);
          sheet.getRangeByName('E2').setText(widget.report.id);
          sheet.getRangeByName('F2').setText(widget.report.year);
          sheet.getRangeByName('G2').setText(widget.report.lastTUV);
          sheet.getRangeByName('H2').setText(widget.report.capcity);
          sheet.getRangeByName('I2').setText(widget.report.typeInspection);
          sheet.getRangeByName('J2').setText("TS-${widget.report.timeSheet}");
          sheet
              .getRangeByName('L2')
              .setText(widget.report.result ?? 'Not Available');
          sheet.getRangeByName('M2').setText(widget.report.location);
          sheet.getRangeByName('N2').setText(widget.report.comments);
          sheet
              .getRangeByName('O2')
              .setText(widget.report.validation ?? 'Not Available');
          sheet
              .getRangeByName('P2')
              .setText(widget.report.stickerNumber ?? 'Not Available');

          sheet.getRangeByName('K2').setText(intl.DateFormat('dd/MM/yyyy')
              .format(widget.report.dateOfSubmit!));

          final List<int> bytes = workbook.saveAsStream();
          if (Platform.isAndroid) {
            final directory = await FilePicker.platform.getDirectoryPath();
            if (directory != null) {
              // save file in the directory (Android only)
              final File file = File('$directory/report.xlsx');
              await file.writeAsBytes(bytes);
              workbook.dispose();
            }
          } else if (Platform.isWindows ||
              Platform.isLinux ||
              Platform.isMacOS) {
            String? result = await FilePicker.platform.saveFile(
              dialogTitle: 'Save the file',
              fileName: 'report.xlsx',
              type: FileType.custom,
              allowedExtensions: ['xlsx'],
            );
            // choose where to save the file
            if (result != null) {
              final File file = File(result);
              await file.writeAsBytes(bytes);
            }
            workbook.dispose();
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File saved successfully')));
          }
        },
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  final int? index;
  final Report? report;
  const RegisterPage({super.key, this.report, this.index});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController equipmentNameController = TextEditingController();
  TextEditingController modalController = TextEditingController();
  TextEditingController serialNumberController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController lastTUVController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController capcityController = TextEditingController();
  TextEditingController typeInspectionController = TextEditingController();
  TextEditingController timeSheetController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  TextEditingController resultController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController validationController = TextEditingController();
  TextEditingController stickerNumberController = TextEditingController();

  late Box<Report> reportsBox;

  // get data if report is not null
  void getData() {
    if (widget.report != null) {
      final Report report = widget.report!;
      companyNameController.text = report.companyName;
      equipmentNameController.text = report.equipmentName;
      modalController.text = report.modal;
      serialNumberController.text = report.serialNumber;
      idController.text = report.id;
      yearController.text = report.year;
      lastTUVController.text = report.lastTUV;
      capcityController.text = report.capcity;
      typeInspectionController.text = report.typeInspection;
      timeSheetController.text = report.timeSheet;
      commentController.text = report.comments;
      resultController.text = report.result ?? '';
      locationController.text = report.location;
      validationController.text = report.validation ?? '';
      stickerNumberController.text = report.stickerNumber ?? '';
    }
  }

  @override
  void initState() {
    super.initState();
    reportsBox = Hive.box<Report>(dbName);
    getData();
  }

  @override
  Widget build(BuildContext context) {
    // check if widget.report is not null to edit

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title:
            widget.report != null ? const Text("Edit") : const Text('Register'),
      ),
      body: Center(
        child: Form(
            child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            // textfield for every controller
            children: [
              const SizedBox(height: 10),
              TextField(
                controller: companyNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Company Name',
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Location',
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: equipmentNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Equipment Name',
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: modalController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Modal',
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: serialNumberController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Serial Number',
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'ID',
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Year',
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: capcityController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Capacity',
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: lastTUVController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Last TUV',
                ),
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Inspection Type',
                ),
                value: typeInspectionController.text,
                items: const [
                  DropdownMenuItem<String>(
                    enabled: false,
                    value: '',
                    child: Text('Type of Inspection',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Visual',
                    child: Text('Visual'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Visual with functional Test',
                    child: Text('Visual with functional Test'),
                  ),
                ],
                onChanged: (String? value) {
                  setState(() {
                    typeInspectionController.text = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              TextField(
                controller: timeSheetController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'TimeSheet',
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Validation',
                ),
                value: validationController.text,
                items: const [
                  DropdownMenuItem<String>(
                    enabled: false,
                    value: '',
                    child: Text('Validation',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  DropdownMenuItem<String>(
                    value: '6 months',
                    child: Text('6 months'),
                  ),
                  DropdownMenuItem<String>(
                    value: '12 months',
                    child: Text('12 months'),
                  ),
                ],
                onChanged: (String? value) {
                  setState(() {
                    validationController.text = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Result',
                ),
                value: resultController.text,
                items: const [
                  DropdownMenuItem<String>(
                    enabled: false,
                    value: '',
                    child: Text('Result', style: TextStyle(color: Colors.grey)),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Pass',
                    child: Text('Pass'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Fail',
                    child: Text('Fail'),
                  ),
                ],
                onChanged: (String? value) {
                  setState(() {
                    resultController.text = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: commentController,
                keyboardType: TextInputType.multiline,
                minLines: 4,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Comment',
                ),
              ),
              const SizedBox(height: 20),

              // sticker number filed
              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                controller: stickerNumberController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Sticker Number',
                ),
              ),

              const SizedBox(height: 20),

              FilledButton.icon(
                icon: widget.report != null
                    ? const Icon(Icons.edit_outlined)
                    : const Icon(Icons.save_alt_outlined),
                onPressed: () async {
                  // check if widget.report is not null to edit
                  if (widget.report != null) {
                    final Report report = widget.report!;
                    report.companyName = companyNameController.text;
                    report.equipmentName = equipmentNameController.text;
                    report.modal = modalController.text;
                    report.serialNumber = serialNumberController.text;
                    report.id = idController.text;
                    report.year = yearController.text;
                    report.lastTUV = lastTUVController.text;
                    report.capcity = capcityController.text;
                    report.typeInspection = typeInspectionController.text;
                    report.timeSheet = timeSheetController.text;
                    report.dateOfSubmit = DateTime.now();
                    report.result = resultController.text;
                    report.location = locationController.text;
                    report.comments = commentController.text;
                    report.validation = validationController.text;
                    report.stickerNumber = stickerNumberController.text;
                    debugPrint(resultController.text);
                    reportsBox.putAt(widget.index!, report);
                    debugPrint('index: ${widget.index}, report: $report');
                  } else {
                    // create new report
                    reportsBox.add(Report(
                      companyName: companyNameController.text,
                      equipmentName: equipmentNameController.text,
                      modal: modalController.text,
                      serialNumber: serialNumberController.text,
                      id: idController.text,
                      year: yearController.text,
                      lastTUV: lastTUVController.text,
                      capcity: capcityController.text,
                      typeInspection: typeInspectionController.text,
                      dateOfSubmit: DateTime.now(),
                      timeSheet: timeSheetController.text,
                      result: resultController.text,
                      location: locationController.text,
                      comments: commentController.text,
                      validation: validationController.text,
                      stickerNumber: stickerNumberController.text,
                    ));
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                label: widget.report != null
                    ? const Text("Update")
                    : const Text('Submit'),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
