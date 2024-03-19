class FilterParameters {
  String filterSearch;
  bool filterDescending;
  DateTime? filterStart;
  DateTime? filterEnd;

  FilterParameters({
    required this.filterSearch,
    required this.filterDescending,
    this.filterStart,
    this.filterEnd,
  });

  setFilterSearch(String value) {
    filterSearch = value;
  }

  setFilterDescending(bool value) {
    filterDescending = value;
  }

  setFilterStart(DateTime? value) {
    filterStart = value;
  }

  setFilterEnd(DateTime? value) {
    filterEnd = value;
  }

  static List<FilterName> orderBy = [
    FilterName(filterName: "Order by Date", filterQueryName: "timestamp"),
    FilterName(
        filterName: "Order by Driver Rating",
        filterQueryName: "feedback_driving_rating"),
    FilterName(
        filterName: 'Order by Driver Email',
        filterQueryName: "feedback_recepient"),
    FilterName(
        filterName: 'Order by Jeepney Rating',
        filterQueryName: "feedback_jeepney_rating"),
    FilterName(
        filterName: 'Order by Jeepney Plate Number',
        filterQueryName: "feedback_jeepney"),
    FilterName(
        filterName: 'Order by Feedback Provider Email',
        filterQueryName: "feedback_sender"),
  ];
}

class FilterName {
  String filterName;
  String filterQueryName;

  FilterName({required this.filterName, required this.filterQueryName});

  setFilterName(String value) {
    filterName = value;
  }

  setFilterQueryName(String value) {
    filterQueryName = value;
  }
}
