
var mongoose = require("mongoose");
var Schema = mongoose.Schema;
var moment = require("moment");
process.env.NODE_ENV = process.env.NODE_ENV || 'development';
var config = require('../config');
var dbMongo = mongoose.connect(config.dbMongo);
var key = config.key;

var CorteModel = require("../../models/corte");
var TicketModel = require("../../models/ticket");
var SpendModel = require("../../models/spend");
var PaybillModel = require("../../models/paybill");
var IngressModel = require("../../models/ingress");
var CarwashModel = require("../../models/carwash");
var UserModel = require("../../models/user");


var Cortes = 90;
var SaveDate = moment().subtract(Cortes, 'days');
var NewCarwash = CarwashModel();
NewCarwash.info.name = "StressTest";
NewCarwash.info.phone = "5549128732";
NewCarwash.info.address = "Some address Here";
NewCarwash.info.type = "1";
NewCarwash.status = true;
NewCarwash.users = [];
NewCarwash.save(function(err){
	if(err){
		console.log("ERROR", err);
	}

	var user = UserModel();
	user.username = "testadmin";
	user.password = "jose12";
	user.info.name = "JOSE GARFIAS ADMIN";
	user.info.phone = "120932123213";
	user.info.birth = Date.now();
	user.info.address = "Some address";
	user.rol = "SuperAdministrador";
	user.save(function(err){
		if(err){
			console.log(err);
		}
	});

	for (var i=0 ; i<Cortes ; i++){
		var DateForSave = moment().subtract((Cortes - i), 'days').format("MM-DD-YYYY");

		//GENERATE THE CORTE:
		var NewCorte = CorteModel();
		NewCorte.lavado_id = NewCarwash._id;
		NewCorte.corte_id = String(i);
		NewCorte.user = "Jose Garfias";
		NewCorte.date = DateForSave;
		NewCorte.save(function(err){
			if(err){
				console.log(err);
			}
		});
		// GENERATE TICKETS:
		var NumberOfTickets = Math.round(Math.random()*(300-250)+parseInt(250));
		console.log("NUMBER OF TICKETS: " + NumberOfTickets);
		for (var j=0; j<NumberOfTickets; j++) {
			var NewTicket = TicketModel();
			NewTicket.lavado_id = NewCarwash._id;
			NewTicket.corte_id = i;
			NewTicket.order_id = String(j);
			NewTicket.status = "Pagado";
			NewTicket.user = "Jose Garfias";
			NewTicket.car = {denomination: 'Carro', price:10};
			NewTicket.services = [{denomination: 'Pulido', price:15},{denomination: 'Aspirado', price:5}];
			NewTicket.entryDate = DateForSave;
			NewTicket.exitDate = DateForSave;
			NewTicket.washingTime = "00:05";
			NewTicket.total = "30";
			NewTicket.date = DateForSave;
			NewTicket.save(function(err){
				if(err){
					console.log("ERROR", err);
				}
			});
		}

		// GENERATE Spends:
		var NumberOfSpends = Math.round(Math.random()*(20-10)+parseInt(10));
		console.log("NUMBER OF SPENDS: " + NumberOfSpends);
		for (var k=0; k<NumberOfSpends; k++) {
			var NewSpend = SpendModel();
			NewSpend.lavado_id = NewCarwash._id;
			NewSpend.corte_id = i;
			NewSpend.denomination = "Gasto #" + String(k);
			NewSpend.total = "10";
			NewSpend.user = "Jose Garfias";
			NewSpend.date = DateForSave;
			NewSpend.save(function(err){
				if(err){
					console.log("ERROR", err);
				}
			});
		}

		// GENERATE Ingresses:
		var NumberOfIngresses = Math.round(Math.random()*(20-10)+parseInt(10));
		console.log("NUMBER OF INGRESSES: " + NumberOfIngresses);
		for (var l=0; l<NumberOfIngresses; l++) {
			var NewIngress = IngressModel();
			NewIngress.lavado_id = NewCarwash._id;
			NewIngress.corte_id = i;
			NewIngress.denomination = "Ingreso #" + String(l);
			NewIngress.total = "20";
			NewIngress.user = "Jose Garfias";
			NewIngress.date = DateForSave;
			NewIngress.save(function(err){
				if(err){
					console.log("ERROR", err);
				}
			});
		}

		// GENERATE Spends:
		var NumberOfPaybills = Math.round(Math.random()*(20-10)+parseInt(10));
		console.log("NUMBER OF PAYBILLS: " + NumberOfPaybills);
		for (var m=0; m<NumberOfPaybills; m++) {
			var NewPaybill = PaybillModel();
			NewPaybill.lavado_id = NewCarwash._id;
			NewPaybill.corte_id = i;
			NewPaybill.denomination = "Paybill #" + String(m);
			NewPaybill.total = "10";
			NewPaybill.user = "Jose Garfias";
			NewPaybill.owner = "Juan Fernando";
			NewPaybill.date = DateForSave;
			NewPaybill.save(function(err){
				if(err){
					console.log("ERROR", err);
				}
			});
		}
	}
});
