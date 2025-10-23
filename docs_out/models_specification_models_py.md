# Module `models\specification_models.py`


## Class `SpecificationItemsModel`


Модель для позиций спецификации (материалов)


### `SpecificationItemsModel.__init__(self, db_manager, parent)`


_No docstring._


### `SpecificationItemsModel.roleNames(self)`


_No docstring._


### `SpecificationItemsModel.rowCount(self, parent)`


_No docstring._


### `SpecificationItemsModel.data(self, index, role)`


_No docstring._


### `SpecificationItemsModel.setData(self, index, value, role)`


_No docstring._


### `SpecificationItemsModel.addItem(self, article, name, quantity, unit, price, image_path, category, status)`


Добавляет материал в список. Если артикул уже есть — увеличивает количество.


### `SpecificationItemsModel.removeItem(self, index)`


Удаляет материал из списка


### `SpecificationItemsModel.clear(self)`


Очищает все позиции


### `SpecificationItemsModel.loadForSpecification(self, spec_id)`


Загружает позиции для спецификации из БД


### `SpecificationItemsModel.getTotalMaterialsCost(self)`


Возвращает общую стоимость материалов


### `SpecificationItemsModel.getItems(self)`


Возвращает список всех позиций для сохранения


### `SpecificationItemsModel.debugPrintItems(self)`


Выводит все элементы модели для отладки


## Class `SpecificationsModel`


Модель для управления спецификациями


### `SpecificationsModel.__init__(self, db_manager, items_model, parent)`


_No docstring._


### `SpecificationsModel.saveSpecification(self, spec_id, name, description, status, labor_cost, overhead_percentage)`


Сохраняет спецификацию с позициями
Возвращает ID спецификации или -1 при ошибке


### `SpecificationsModel.loadSpecification(self, spec_id)`


Загружает спецификацию для редактирования


### `SpecificationsModel.deleteSpecification(self, spec_id)`


Удаляет спецификацию


### `SpecificationsModel.loadAllSpecifications(self)`


Загружает все спецификации для отображения в списке


### `SpecificationsModel.loadSpecificationItems(self, spec_id)`


Загружает позиции спецификации для отображения


### `SpecificationsModel.exportToExcel(self, spec_id)`


Экспорт спецификации в Excel


### `SpecificationsModel.exportToPDF(self, spec_id)`


Экспорт спецификации в PDF

