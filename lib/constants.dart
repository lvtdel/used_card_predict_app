class Constants {
  static const api_url = "http://localhost:8000/api/v1";
  static const url_predict = "$api_url/predict";
  static const url_get_brands = "$api_url/brands";

  static const input_state = "INPUT_STATE";
  static const load_state = "LOAD_STATE";
  static const watch_state = "WATCH_STATE";
}

class BuildUrl {
  static String build_url_get_models_by_brand(String brand) {
    return "${Constants.api_url}/brands/$brand/models";
  }

  static String buil_url_predict(double car_mileage, double car_age,
      double car_engine_hp, String car_brand, String car_model) {
    return "${Constants.url_predict}?"
        "car_mileage=$car_mileage"
        "&car_age=$car_age"
        "&car_engine_hp=$car_engine_hp"
        "&car_brand=$car_brand"
        "&car_model=$car_model";
  }
}
