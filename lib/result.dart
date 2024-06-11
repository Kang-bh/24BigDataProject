import 'dart:convert';
import 'package:bigdata_project/Model/model.dart';
import 'package:bigdata_project/ReportChartBody/courseBody.dart';
import 'package:bigdata_project/ReportChartBody/chartBody.dart';
import 'package:bigdata_project/ReportChartBody/pieChartBody.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Result extends StatefulWidget {
  const Result({super.key, required this.devType, required this.role});

  final String? devType;
  final String? role;

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  late Future<ApiResponse> futureResponse;

  @override
  void initState() {
    super.initState();
    futureResponse = fetchApiResponse();
  }

  Future<ApiResponse> fetchApiResponse() async {
    final response = await http.get(
      Uri.parse(
          'http://3.34.56.115:3000/devs/report?devType=${widget.devType}&role=${widget.role}'),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load API data');
    }
  }

  List<int> calculatePercentages(List<int> values) {
    int total = values.reduce((a, b) => a + b);
    return values.map((value) => ((value / total) * 100).toInt()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('결과'),
      ),
      body: Center(
        child: FutureBuilder<ApiResponse>(
          future: futureResponse,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              final List<String> editorTitles =
                  data.result.editorRank.map((rank) => rank.name).toList();
              final List<int> editorValues =
                  data.result.editorRank.map((rank) => rank.count).toList();
              final List<int> editorpercentages =
                  calculatePercentages(editorValues);
              final List<String> langTitles =
                  data.result.langRank.map((rank) => rank.name).toList();
              final List<int> langValues =
                  data.result.langRank.map((rank) => rank.count).toList();
              final List<int> langpercentages =
                  calculatePercentages(langValues);
              final List<String> frameworkTitles =
                  data.result.frameworkRank.map((rank) => rank.name).toList();
              final List<int> frameworkValues =
                  data.result.frameworkRank.map((rank) => rank.count).toList();
              final List<int> frameworkpercentages =
                  calculatePercentages(frameworkValues);
              final List<Widget> courseBodies =
                  data.result.recommendLectures.map((lecture) {
                return CourseBody(
                  title: lecture.title,
                  content: lecture.imageUrl,
                  url: lecture.linkUrl,
                );
              }).toList();
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        '개발자가 사용하는 IDE, Editor',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      CustomBarChart(
                        titles: editorTitles,
                        values: editorpercentages,
                      ),
                      const Divider(),
                      const Text(
                        '언어 순위',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      CustomBarChart(
                        titles: langTitles,
                        values: langpercentages,
                      ),
                      const Text(
                        '프레임워크 순위',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      CustomBarChart(
                        titles: frameworkTitles,
                        values: frameworkpercentages,
                      ),
                      const Divider(),
                      const Text(
                        '코드에 사용하는 시간',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      const Text(
                        '주에 일하는 시간',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      const Text(
                        '효율을 늘리기 위한 방법?',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      const Text(
                        '자는 시간',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const PieChartSample2(
                        sectionTitles: ['4시간', '8시간', '6시간'],
                        sectionValues: ['30%', '15%', '15%'],
                      ),
                      const Divider(),
                      const Text(
                        '추천 강의',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: courseBodies,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Text('No data');
            }
          },
        ),
      ),
    );
  }
}
