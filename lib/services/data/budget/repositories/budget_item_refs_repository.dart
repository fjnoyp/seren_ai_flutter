import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/budget/budget_item_field_enum.dart';
import 'package:seren_ai_flutter/services/data/budget/models/budget_item_ref_model.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';

final budgetItemRefsRepositoryProvider =
    Provider<BudgetItemReferencesRepository>((ref) {
  return BudgetItemReferencesRepository(ref.watch(dbProvider), ref);
});

class BudgetItemReferencesRepository
    extends BaseRepository<BudgetItemRefModel> {
  final Ref ref;

  const BudgetItemReferencesRepository(super.db, this.ref,
      {super.primaryTable = 'budget_item_references'});

  @override
  BudgetItemRefModel fromJson(Map<String, dynamic> json) {
    return BudgetItemRefModel.fromJson(json);
  }

  Stream<List<BudgetItemRefModel>> watchBudgetItems({
    required String orgId,
  }) {
    return Stream.periodic(const Duration(seconds: 1))
        .map((_) => _getMockedSinapiScBudgetItems());
    // return watch(
    //   BudgetQueries.budgetItemsQuery,
    //   {
    //     'org_id': orgId,
    //   },
    // );
  }

  Future<List<BudgetItemRefModel>> getBudgetItems({
    required String orgId,
  }) async {
    return _getMockedSinapiScBudgetItems();
    // return get(
    //   BudgetQueries.budgetItemsQuery,
    //   {
    //     'org_id': orgId,
    //   },
    // );
  }

  Stream<BudgetItemRefModel> watchBudgetItemById({
    required String budgetItemId,
  }) {
    return Stream.periodic(const Duration(seconds: 1)).map((_) =>
        _getMockedSinapiScBudgetItems()
            .firstWhere((item) => item.id == budgetItemId));
    // return watchSingle(
    //   BudgetQueries.getBudgetItemQuery,
    //   {
    //     'item_id': budgetItemId,
    //   },
    // );
  }

  Future<BudgetItemRefModel> getBudgetItemById({
    required String budgetItemId,
  }) async {
    return _getMockedSinapiScBudgetItems()
        .firstWhere((item) => item.id == budgetItemId);
    // return getSingle(
    //   BudgetQueries.getBudgetItemQuery,
    //   {
    //     'item_id': budgetItemId,
    //   },
    // );
  }

  Future<void> updateBudgetItemField({
    required String budgetItemId,
    required BudgetItemFieldEnum field,
    required String value,
  }) async {
    // TODO p0: Implement this
    print('updateBudgetItemField: $budgetItemId, $field, $value');
  }

  List<BudgetItemRefModel> _getMockedSinapiScBudgetItems() {
    // This is a mocked implementation that returns data from the JSON
    return [
      BudgetItemRefModel(
        id: '19659318',
        type: 'MATERIAL',
        code: '1',
        source: 'SINAPI SC 12/2024',
        name:
            'ACETILENO (RECARGA DE GAS ACETILENO PARA CILINDRO DE CONJUNTO OXICORTE GRANDE) NAO INCLUI TROCA/MANUTENCAO DO CILINDRO',
        measureUnit: 'KG',
        baseUnitValue: 81.11, // valorNaoOnerado
      ),
      BudgetItemRefModel(
        id: '19662001',
        type: 'MATERIAL',
        code: '100',
        source: 'SINAPI SC 12/2024',
        name:
            'ADAPTADOR PVC, SOLDAVEL, COM FLANGES E ANEL DE VEDACAO, 60 MM X 2\", PARA CAIXA D\'AGUA',
        measureUnit: 'UN',
        baseUnitValue: 43.58, // valorNaoOnerado
      ),
      BudgetItemRefModel(
        id: '19659956',
        type: 'MATERIAL',
        code: '1000',
        source: 'SINAPI SC 12/2024',
        name:
            'CABO DE COBRE, FLEXIVEL, CLASSE 4 OU 5, ISOLACAO EM PVC/A, ANTICHAMA BWF-B, COBERTURA PVC-ST1, ANTICHAMA BWF-B, 1 CONDUTOR, 0,6/1 KV, SECAO NOMINAL 185 MM2',
        measureUnit: 'M',
        baseUnitValue: 197.31, // valorNaoOnerado
      ),
      BudgetItemRefModel(
        id: '19666842',
        type: 'FUNDACOES E ESTRUTURAS',
        code: '100064',
        source: 'SINAPI SC 12/2024',
        name:
            'ARMAÇÃO DO SISTEMA DE PAREDES DE CONCRETO, EXECUTADA COMO ARMADURA POSITIVA DE LAJES, TELA Q-159. AF_12/2024',
        measureUnit: 'KG',
        baseUnitValue: 11.13, // valorNaoOnerado
      ),
      BudgetItemRefModel(
        id: '19666843',
        type: 'FUNDACOES E ESTRUTURAS',
        code: '100066',
        source: 'SINAPI SC 12/2024',
        name:
            'ARMAÇÃO DO SISTEMA DE PAREDES DE CONCRETO, EXECUTADA COMO ARMADURA POSITIVA DE LAJES, TELA Q-196. AF_12/2024',
        measureUnit: 'KG',
        baseUnitValue: 11.17, // valorNaoOnerado
      ),
      BudgetItemRefModel(
        id: '19666844',
        type: 'FUNDACOES E ESTRUTURAS',
        code: '100067',
        source: 'SINAPI SC 12/2024',
        name:
            'ARMAÇÃO DO SISTEMA DE PAREDES DE CONCRETO, EXECUTADA COMO REFORÇO, VERGALHÃO DE 5,0 MM DE DIÂMETRO. AF_12/2024',
        measureUnit: 'KG',
        baseUnitValue: 12.23, // valorNaoOnerado
      ),
      BudgetItemRefModel(
        id: '19666845',
        type: 'FUNDACOES E ESTRUTURAS',
        code: '100068',
        source: 'SINAPI SC 12/2024',
        name:
            'ARMAÇÃO DO SISTEMA DE PAREDES DE CONCRETO, EXECUTADA COMO REFORÇO, VERGALHÃO DE 12,5 MM DE DIÂMETRO. AF_12/2024',
        measureUnit: 'KG',
        baseUnitValue: 8.99, // valorNaoOnerado
      ),
      BudgetItemRefModel(
        id: '19659957',
        type: 'MATERIAL',
        code: '1001',
        source: 'SINAPI SC 12/2024',
        name:
            'CABO DE COBRE, FLEXIVEL, CLASSE 4 OU 5, ISOLACAO EM PVC/A, ANTICHAMA BWF-B, COBERTURA PVC-ST1, ANTICHAMA BWF-B, 1 CONDUTOR, 0,6/1 KV, SECAO NOMINAL 300 MM2',
        measureUnit: 'M',
        baseUnitValue: 340.19, // valorNaoOnerado
      ),
      BudgetItemRefModel(
        id: '19669779',
        type: 'INSTALACOES HIDRO SANITARIAS',
        code: '100128',
        source: 'SINAPI SC 12/2024',
        name:
            'TIL (TUBO DE INSPEÇÃO E LIMPEZA) RADIAL PARA ESGOTO, EM PVC, DN 300X200 MM. AF_12/2020',
        measureUnit: 'UN',
        baseUnitValue: 1419.75, // valorNaoOnerado
      ),
      BudgetItemRefModel(
        id: '19671186',
        type: 'SERVICOS DIVERSOS',
        code: '100195',
        source: 'SINAPI SC 12/2024',
        name:
            'TRANSPORTE HORIZONTAL MANUAL, DE SACOS DE 50 KG (UNIDADE: KGXKM). AF_07/2019',
        measureUnit: 'KGXKM',
        baseUnitValue: 0.77, // valorNaoOnerado
      ),
    ];
  }
}
