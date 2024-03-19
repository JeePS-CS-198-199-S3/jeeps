import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_web/components/button.dart';
import 'package:transitrack_web/models/filter_model.dart';
import 'package:transitrack_web/style/constants.dart';
import 'package:transitrack_web/style/style.dart';

class Filters extends StatefulWidget {
  final FilterParameters oldFilter;
  final ValueChanged<FilterParameters> newFilter;
  const Filters({super.key, required this.oldFilter, required this.newFilter});

  @override
  State<Filters> createState() => FiltersState();
}

class FiltersState extends State<Filters> {
  FilterName? orderBy;

  @override
  void initState() {
    super.initState();

    setState(() {
      orderBy = FilterName(
          filterName: FilterParameters.orderBy
              .firstWhere((element) =>
                  element.filterQueryName == widget.oldFilter.filterSearch)
              .filterName,
          filterQueryName: widget.oldFilter.filterSearch);
    });
  }

  void toggleFilter(int index) {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: Constants.defaultPadding,
          right: Constants.defaultPadding,
          bottom: Constants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            children: [
              PrimaryText(
                text: "Advanced Search",
                color: Colors.white,
                size: 40,
                fontWeight: FontWeight.w700,
              )
            ],
          ),
          const Divider(color: Colors.white),
          const SizedBox(height: Constants.defaultPadding),
          DropdownButton<String>(
            padding: const EdgeInsets.symmetric(
                horizontal: Constants.defaultPadding),
            value: orderBy!.filterName,
            isExpanded: true,
            onChanged: (String? newValue) {
              setState(() {
                orderBy = FilterName(
                    filterName: newValue!,
                    filterQueryName: FilterParameters.orderBy
                        .firstWhere((element) => element.filterName == newValue)
                        .filterQueryName);
              });
            },
            items: FilterParameters.orderBy
                .map<DropdownMenuItem<String>>((FilterName value) {
              return DropdownMenuItem<String>(
                value: value.filterName,
                child: Text(value.filterName),
              );
            }).toList(),
            hint: const Text('Order By'), // Optional
          ),
          const SizedBox(height: Constants.defaultPadding),
          const Divider(color: Colors.white),
          const SizedBox(height: Constants.defaultPadding),
          Button(
              onTap: () {
                widget.newFilter(FilterParameters(
                    filterSearch: orderBy!.filterQueryName,
                    filterDescending: true));
                Navigator.pop(context);
              },
              text: "Search")
        ],
      ),
    );
  }
}
