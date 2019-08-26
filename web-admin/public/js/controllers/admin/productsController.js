angular.module('ProductsCtrl',[]).controller('ProductsController',function($scope,$mdDialog,CarwashVars,ProductServ,CarwashServ,StockServ){

	var self = this;

	var Profile = CarwashVars.GetUser();
	console.log(Profile);

	//initialize 'seccion'
	self.Producto = {
		denomination: null,
		price: null
	}
	self.Stock = {

	};

	self.isEditing = {
		flag: false,
		id: null
	};

	self.options = {
	  	format: 'yyyy-mm-dd', 
	  	formatSubmit: 'yyyy-mm-dd',
		monthsFull: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
		monthsShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
		weekdaysFull: ['Domingo', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado'],
		weekdaysShort: ['Dom', 'Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab'],
		today: 'Hoy',
		clear: 'Cerrar',
		firstDay: 1
	}

	function ClearTextFields(){

		self.Producto.denomination = null;
		self.Producto.price = null;

		self.isEditing.flag = false;
		self.isEditing.id = null;

		self.SelectedProduct = null;
		self.Stock = {};
		
	}

	function Alerta(title, message){

		$mdDialog.show( $mdDialog.alert()
	        .parent(angular.element(document.body))
	        .title(title)
	        .content(message)
	        .ariaLabel('Alert Dialog Demo')
	        .ok('OK')
		);

	}

	function ReloadData(){
		self.ProductsOnDB = [];
		if(Profile.rol == "SuperAdministrador"){
			ProductServ.All(function(data){
				self.ProductsOnDB = data.products;
				console.log(self.ProductsOnDB);
			});	
		}

		CarwashServ.All(function(data){
			console.log(data);
			self.CarwashesOnDB = data.carwashes;
		});	


	}

	ReloadData();


	self.Submit = function(){

		if (self.Producto.denomination != undefined && 
			self.Producto.price != undefined ){

			if(self.isEditing.flag){

				ProductServ.Update(self.isEditing.id,self.Producto).success(function(data){

					if(data.success){
						Alerta('Producto Actualizado.',data.message);

						ReloadData();
						ClearTextFields();

					}else{
						Alerta('Error',data.message);
					}

				}).error(function(data){
					Alerta('Error',data.message);
		       	});

			}else{		
				ProductServ.Create(self.Producto).success(function(data){
					if(data.success){

						Alerta('Producto Agregado.',data.message);

						ReloadData();
						ClearTextFields();

					}else{
						Alerta('Error',data.message);
					}
				}).error(function(data){
					Alerta('Error',data.message);
		       	});
			}
		}else{
			Alerta('Datos Incompletos','Favor de rellenar todos los campos.');
		}
	}

	self.Edit = function(ProductDB){

		ClearTextFields();

		self.Producto.denomination = ProductDB.denomination;
		self.Producto.price = ProductDB.price;

		self.isEditing.flag = true;
		self.isEditing.id = ProductDB._id;

	}

	self.CancelEditing = function(){
		ClearTextFields();
	}

	self.Delete = function(ProductDB){
		ProductServ.Delete(ProductDB._id).success(function(data){
			Alerta('Producto Eliminado',data.message);
			ReloadData();
			ClearTextFields();
		}).error(function(data){
			Alerta('Error',data.message);
	    });
	}

	self.SubmitDeliver = function(){

		self.Stock.lavado_id = [];
		angular.forEach(self.CarwashesOnDB, function(carwash, key) {
			if(carwash.isSelected){
				self.Stock.lavado_id.push(carwash._id);
			}
		});

		if(self.Stock.quantity != undefined &&
			self.SelectedProduct != undefined &&
			self.Stock.deliverDate != undefined &&
			self.Stock.lavado_id.length > 0){

			angular.forEach(self.ProductsOnDB, function(product, key) {
				if(product._id == self.SelectedProduct){
					self.Stock.product = {};
					self.Stock.product.denomination = product.denomination;
					self.Stock.product.price = product.price;
					self.Stock.product.quantity = self.Stock.quantity;
				}
			});

			StockServ.Create(self.Stock).success(function(data){
				if(data.success){

					Alerta('Producto De Entrega Agregado.',data.message);

					ReloadData();
					ClearTextFields();

				}else{
					Alerta('Error',data.message);
				}
			}).error(function(data){
				Alerta('Error',data.message);
	       	});


		}else{
			Alerta('Datos Incompletos','Favor de rellenar todos los campos.');
		}

	}

});