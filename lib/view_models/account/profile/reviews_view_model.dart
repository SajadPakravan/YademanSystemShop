import 'package:yad_sys/models/review_item_model.dart';
import 'package:yad_sys/models/review_items_response_model.dart';
import 'package:yad_sys/view_models/account/profile/account_list_view_model.dart';

class ReviewsViewModel extends AccountListViewModel<ReviewItemModel> {
  ReviewsViewModel({required super.token, super.httpRequest});

  @override
  String get loadErrorMessage => 'دریافت نظرات شما انجام نشد.';

  @override
  Future<dynamic> request() => httpRequest.getCustomerComments(token: token);

  @override
  AccountListLoadResult<ReviewItemModel> parse(Map<String, dynamic> json) {
    final model = ReviewItemsResponseModel.fromJson(json);
    return AccountListLoadResult(success: model.success, count: model.count, items: model.data);
  }
}
