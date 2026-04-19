class CategorySpendingResponse {
  final double totalBudget; // Cambiado para coincidir con Python
  final List<CategorySpendingItem> categories;

  CategorySpendingResponse({
    required this.totalBudget,
    required this.categories,
  });

  factory CategorySpendingResponse.fromJson(Map<String, dynamic> json) {
    return CategorySpendingResponse(
      // ⭐ Python manda 'total_budget'
      totalBudget: (json['total_budget'] as num?)?.toDouble() ?? 0.0,
      categories: (json['categories'] as List? ?? [])
          .map((item) => CategorySpendingItem.fromJson(item))
          .toList(),
    );
  }
}

class CategorySpendingItem {
  final String categoryName;
  final double amount;
  final double percentage;

  CategorySpendingItem({
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  factory CategorySpendingItem.fromJson(Map<String, dynamic> json) {
    return CategorySpendingItem(
      categoryName: json['category_name'] ?? 'Sin categoría',
      // ⭐ Python manda 'total_spent', no 'amount'
      amount: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
