angular.module('CarwashCtrl',[]).controller('CarwashController',function($rootScope,$scope,CarwashServ,$mdDialog){

	var self = this;


//initialize 'seccion'
	self.Lavado = {
		name: null,
		address: null,
		phone: null,
		type: null
	}

	self.isEditing = {
		flag: false,
		id: null
	};


	function ClearTextFields(){

		self.Lavado.name = null;
		self.Lavado.address = null;
		self.Lavado.phone = null;
		self.Lavado.type = null;

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

		CarwashServ.All().then(function(data){
			self.CarwashesOnDB = data.data.carwashes;
		});
	}
	ReloadData();


	self.Submit = function(){

		console.log("here in function");

		if (self.Lavado.name != undefined &&
			self.Lavado.address != undefined &&
			self.Lavado.phone != undefined &&
			self.Lavado.type != undefined ){

			if(self.isEditing.flag){


				CarwashServ.Update(self.isEditing.id,self.Lavado).then(function(data){

					if(data.data.success){

						Alerta('Autolavado Actualizado.',data.data.message);

						ReloadData();
						ClearTextFields();

						self.isEditing.flag = false;
						self.isEditing.id = null;

						$scope.$emit('ReloadCarwashes');


					}else{
						Alerta('Error',data.message);
					}

				}).catch(function(data){
					Alerta('Error',data.data.message);
		       	});

			}else{
				CarwashServ.Create(self.Lavado).then(function(data){

					if(data.data.success){

						Alerta('Autolavado Agregado.',data.data.message);

						ReloadData();
						ClearTextFields();
						$scope.$emit('ReloadCarwashes');

					}else{
						Alerta('Error',data.data.message);
					}
				}).catch(function(data){
					Alerta('Error',data.data.message);
		       	});
			}
		}else{
			Alerta('Datos Incompletos','Favor de rellenar todos los campos.');
		}
	}

	self.Edit = function(CarwashDB){

		ClearTextFields();

		self.Lavado.name = CarwashDB.info.name;
		self.Lavado.address = CarwashDB.info.address;
		self.Lavado.phone = CarwashDB.info.phone;
		self.Lavado.type = CarwashDB.info.type;

		self.isEditing.flag = true;
		self.isEditing.id = CarwashDB._id;

	}

	self.CancelEditing = function(){

		ClearTextFields();

		self.isEditing.flag = false;
		self.isEditing.id = null;

	}

	self.Delete = function(CarwashDB){

		CarwashServ.Delete(CarwashDB._id).then(function(data){

			Alerta('Autolavado Eliminado',data.data.message);

			ReloadData();
			ClearTextFields();

			self.isEditing.flag = false;
			self.isEditing.id = null;

			$scope.$emit('ReloadCarwashes');

		}).catch(function(data){
			Alerta('Error',data.message);
	    });
	}

});
