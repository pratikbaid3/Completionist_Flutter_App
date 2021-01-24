import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Provider/game_provider.dart';
import 'package:game_trophy_manager/Provider/graph_provider.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:provider/provider.dart';

class LineChartSample2 extends StatefulWidget {
  @override
  _LineChartSample2State createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    primaryAccentColor,
    secondaryAccentColor,
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: primaryColor),
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 18.0, left: 2.0, top: 24, bottom: 12),
              child: LineChart(
                mainData(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              // case 0:
              //   return 'J';
              // case 1:
              //   return 'F';
              case 2:
                return 'JAN';
              // case 3:
              //   return 'A';
              // case 4:
              //   return 'M';
              // case 5:
              //   return 'J';
              case 5:
                return 'FEB';
              // case 7:
              //   return 'A';
              // case 8:
              //   return 'S';
              // case 9:
              //   return 'O';
              case 8:
                return 'MAR';
              // case 11:
              //   return 'D';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return (Provider.of<GraphProvider>(context, listen: false)
                            .yAxis *
                        0)
                    .toInt()
                    .toString();
              case 2:
                return (Provider.of<GraphProvider>(context, listen: false)
                            .yAxis *
                        2)
                    .toInt()
                    .toString();
              case 4:
                return (Provider.of<GraphProvider>(context, listen: false)
                            .yAxis *
                        4)
                    .toInt()
                    .toString();
              case 6:
                return (Provider.of<GraphProvider>(context, listen: false)
                            .yAxis *
                        6)
                    .toInt()
                    .toString();
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: const Color(0xff37434d),
          width: 1,
        ),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0.1, 0),
            FlSpot(
                2,
                (Provider.of<GraphProvider>(context).jan) /
                    Provider.of<GraphProvider>(context).yAxis),
            FlSpot(
                5,
                (Provider.of<GraphProvider>(context).feb) /
                    Provider.of<GraphProvider>(context).yAxis),
            FlSpot(
                8,
                (Provider.of<GraphProvider>(context).march) /
                    Provider.of<GraphProvider>(context).yAxis),
            FlSpot(10.9, 0),
            // FlSpot(
            //     3,
            //     Provider.of<GraphProvider>(context).april *
            //         Provider.of<GraphProvider>(context, listen: false).yAxis),
            // FlSpot(
            //     4,
            //     Provider.of<GraphProvider>(context).may *
            //         Provider.of<GraphProvider>(context, listen: false).yAxis),
            // FlSpot(
            //     5,
            //     Provider.of<GraphProvider>(context).june *
            //         Provider.of<GraphProvider>(context, listen: false).yAxis),
            // FlSpot(
            //     6,
            //     Provider.of<GraphProvider>(context).july *
            //         Provider.of<GraphProvider>(context, listen: false).yAxis),
            // FlSpot(
            //     7,
            //     Provider.of<GraphProvider>(context).aug *
            //         Provider.of<GraphProvider>(context, listen: false).yAxis),
            // FlSpot(
            //     8,
            //     Provider.of<GraphProvider>(context).sept *
            //         Provider.of<GraphProvider>(context, listen: false).yAxis),
            // FlSpot(
            //     9,
            //     Provider.of<GraphProvider>(context).oct *
            //         Provider.of<GraphProvider>(context, listen: false).yAxis),
            // FlSpot(
            //     10,
            //     Provider.of<GraphProvider>(context).nov *
            //         Provider.of<GraphProvider>(context, listen: false).yAxis),
            // FlSpot(
            //     11,
            //     Provider.of<GraphProvider>(context).dec *
            //         Provider.of<GraphProvider>(context, listen: false).yAxis),
          ],
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }
}
