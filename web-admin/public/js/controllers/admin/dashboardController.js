angular.module('DashboardCtrl',[]).controller('DashboardController',function($rootScope,$scope,$timeout,CarwashVars,DashboardServ,Socket,TicketAServ,CortesServ){

	var self = this;
	var Profile = CarwashVars.GetUser();
	var CarwashActive = CarwashVars.GetCarwash();

	$scope.$on('ChangeCarwash', function (event, data) {
    	CarwashActive = data;
		ReloadActiveTickets();
		ReloadDataDashboard();
  	});
	Socket.on("connect", function(data){
		Socket.emit('ConnectedAdmin', {
			user_name: Profile.name,
			user_id: Profile.id,
			device: "Web"
		});
	});
	Socket.on('refreshActiveTickets', function (data) {
		console.log("RefreshActiveTickets",data);
		if(data.carwash_id == CarwashActive){
			ReloadActiveTickets();
		}
	});
	Socket.on('refreshDashboard', function (data) {
		console.log("RefreshDashboard",data);
		if(data.carwash_id == CarwashActive){
			ReloadDataDashboard();
			ReloadActiveTickets();
		}
	});
	//vars Initialization:
	var actualCorte = 0;
	function ReloadActiveTickets(){
		self.ActiveTicketsOnDB = [];
		TicketAServ.AllByLavado(CarwashActive).then(function(TicketData){
			if(TicketData.success){
				self.ActiveTicketsOnDB = TicketData.activetickets;
				self.ActiveTicketsCount = self.ActiveTicketsOnDB.length;
				angular.forEach(self.ActiveTicketsOnDB, function(ticket, key) {
					ticket.created = moment(ticket.created).format('HH:mm');
				});
			}else{
			}
		});

	}
	function ReloadDataDashboard(){
		//calcular el ultimo corte activo el lavado:
		self.isLoading = true;
		CortesServ.AllByLavado(CarwashActive).then(function(data){
			if(data.cortes.length > 0){
				actualCorte = data.cortes.length;
			}
			console.log("CorteActual" , actualCorte);
			if(CarwashActive == 0){
			}else{
				//GET DASHBOARD:
				DashboardServ.AllByLavado(CarwashActive,actualCorte).then(function(data){
					if(data.success){
						self.TotalTickets = data.tickets.total;
						self.TotalSpends = data.spends.total;
						self.TotalIngresses = data.ingresses.total;
						self.TotalPaybills = data.paybills.total;
						self.CountTickets = data.tickets.count;
						self.CountSpends = data.spends.count;
						self.CountIngresses = data.ingresses.count;
						self.CountPaybills = data.paybills.count;
						self.TotalGanancias = (self.TotalTickets + self.TotalIngresses) - (self.TotalSpends + self.TotalPaybills);
					}else{
						Alerta('Error',data.message);
					}
				}).error(function(data){
					Alerta('Error',data.message);
		       	});
			}
		});
	}
	if(CarwashActive != 0){
		ReloadActiveTickets();
		ReloadDataDashboard();
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
});
