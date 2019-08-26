//MODELS
var TicketModel = require("../models/ticket");
var SpendModel = require("../models/spend");
var IngressModel = require("../models/ingress");
var PaybillModel = require("../models/paybill");
var UserModel = require("../models/user");
var CorteModel = require("../models/corte");
var PendingModel = require("../models/pending");

var mongoose = require("mongoose");
var moment = require("moment");
var async = require("async");

var Schema = mongoose.Schema;
var ObjectId = mongoose.Types.ObjectId;


module.exports = {

	// USE THE AGGREGATE QUERY: (CHANGE NAME FOR RESUME) => USED IN IPHONE APP FOR HISTORY.
	// Final Day have to be greather cuz the operator y LOWER THAN & No Equals.

	DashboardByLavado: function(req,res){
		var Tasks = [];
		var Query;
			var lavado_id = new ObjectId(req.params.lavado_id);

		if(req.body.initialDate && req.body.finalDate){
			var initialDate = moment(req.body.initialDate).toDate();
			var finalDate = moment(req.body.finalDate).toDate();
			if(req.body.corte_id){
				Query = {
					lavado_id: lavado_id,
					corte_id: String(req.body.corte_id),
					date: {
						$gte: initialDate,
						$lt: finalDate
					}
				};
			}else{
				Query = {
					lavado_id: lavado_id,
					date: {
						$gte: initialDate,
						$lt: finalDate
					}
				};
			}
		}else if(req.body.corte_id){
			Query = {
				lavado_id: lavado_id,
				corte_id: String(req.body.corte_id)
			};
		}else{
			var initialDate = moment().format('YYYY-MM-DD');
			var finalDate = moment().add(1,'day').format('YYYY-MM-DD');
			Query = {
				lavado_id: lavado_id,
				date: {
					$gte: initialDate,
					$lt: finalDate
				}
			};
		}

		//retrive all the tickets.
		Tasks.push(function(callback){
			TicketModel.aggregate([
				{$match: Query},
				{$group: {_id: "$lavado_id",count: {$sum: 1},total: {$sum: "$total"}}
			}], function (err, result){
				if(err){
					res.json({success:false,error:err});
				}
				if (result.length > 0) {
					callback(null,{'name':'tickets','count':result[0].count, 'total':result[0].total });
				} else{
					callback(null,{'name':'tickets','count':0, 'total':0 });
				}
			});
		});

		//retrive all the spends.
		Tasks.push(function(callback){
			SpendModel.aggregate([
				{$match: Query},
				{$group: {_id: "$lavado_id",count: {$sum: 1},total: {$sum: "$total"}}
			}], function (err, result){
				if(err){
					res.json({success:false,error:err});
				}
				if (result.length > 0){
					callback(null,{'name':'spends','count':result[0].count, 'total':result[0].total });
				}else {
					callback(null,{'name':'spends','count':0, 'total':0 });
				}
			});
		});

		//retrive all the Ingresses.
		Tasks.push(function(callback){
			IngressModel.aggregate([
				{$match: Query},
				{$group: {_id: "$lavado_id",count: {$sum: 1},total: {$sum: "$total"}}
			}], function (err, result){
				if(err){
					res.json({success:false,error:err});
				}
				if(result.length > 0 ){
					callback(null,{'name':'ingresses','count':result[0].count, 'total':result[0].total });
				}else{
					callback(null,{'name':'ingresses','count':0, 'total':0 });
				}
			});
		});
		//retrive all the Bills.
		Tasks.push(function(callback){
			PaybillModel.aggregate([
				{$match: Query},
				{$group: {_id: "$lavado_id",count: {$sum: 1},total: {$sum: "$total"}}
			}], function (err, result){
				if(err){
					res.json({success:false,error:err});
				}
				if(result.length > 0){
					callback(null,{'name':'paybills','count':result[0].count, 'total':result[0].total });
				}else{
					callback(null,{'name':'paybills','count':0, 'total':0 });
				}
			});
		});

		async.series(Tasks, function(err, result) {
				if (err){
					console.log(err);
				}
				var historyReturn = {};
				historyReturn.success = true;
				result.forEach(function(obj){
					historyReturn[obj.name] = {
						count: obj.count,
						total: obj.total
					};
				});
				if(historyReturn){
					res.json(historyReturn);
				}else{
					res.json({success: false , message:'Ocurrio algun error.'});
				}
		});
	},

	// USE THE PAGINATOR QUERY FOR WEB DETAIL: (FOUR PAGINATORS...)
	AllHistoryByLavado: function(req,res){

		var Tasks = [];
		var Query;
		var lavado_id = new ObjectId(req.params.lavado_id);
		var Paginator = {
			page: 1,
			limit: 10
		};
		if (req.body.page){
			Paginator.page = req.body.page;
		}
		if (req.body.limit) {
			Paginator.limit = req.body.limit;
		}
		if(req.body.initialDate && req.body.finalDate){
			var initialDate = moment(req.body.initialDate).toDate();
			var finalDate = moment(req.body.finalDate).toDate();

			if(req.body.corte_id){
				Query = {
					lavado_id: lavado_id,
					corte_id: String(req.body.corte_id),
					date: {
						$gt: initialDate,
						$lt: finalDate
					}
				};
			}else{
				Query = {
					lavado_id: lavado_id,
					date: {
						$gt: initialDate,
						$lt: finalDate
					}
				};
			}
		}else if(req.body.corte_id){
			Query = {
				lavado_id: lavado_id,
				corte_id: String(req.body.corte_id)
			};
		}else{
			var initialDate = moment().format('YYYY-MM-DD');
			var finalDate = moment().add(1,'day').format('YYYY-MM-DD');
			Query = {
				lavado_id: lavado_id,
				date: {
					$gt: initialDate,
					$lt: finalDate
				}
			};
		}

		//retrive all the tickets.
		Tasks.push(function(callback){
			TicketModel.paginate(Query,Paginator, function(err, result) {
				if(err){
					res.json({success:false,error:err});
				}else{
					callback(null,{'name':'tickets','data': result});
				}
			});
		});

		//retrive all the spends.
		Tasks.push(function(callback){
			SpendModel.paginate(Query,Paginator, function(err, result) {
				if(err){
					res.json({success:false,error:err});

				}else{
					callback(null,{'name':'spends','data': result});
				}
			});
		});

		//retrive all the Ingresses.
		Tasks.push(function(callback){
			IngressModel.paginate(Query,Paginator, function(err, result) {
				if(err){
					res.json({success:false,error:err});
				}else{
					callback(null,{'name':'ingresses','data': result});
				}
			});
		});
		//retrive all the Bills.
		Tasks.push(function(callback){
			PaybillModel.paginate(Query,Paginator, function(err, result) {
				if(err){
					res.json({success:false,error:err});
				}else{
					callback(null,{'name':'paybills','data': result});
				}
			});
		});

		async.series(Tasks, function(err, result) {
            if (err){
                console.log(err);
            }
            var historyReturn = {};
            historyReturn.success = true;
			result.forEach(function(obj){
				historyReturn[obj.name] = obj.data;
			});
			if(historyReturn){
	    		res.json(historyReturn);
			}else{
				res.json({success: false , message:'Ocurrio algun error.'});
			}
        });
	},

	UpdateByLavado: function(req,res){

		var TokenObj = req.decoded;
		var Tasks = [];

		req.body.tickets.forEach(function(reqTicket){
			Tasks.push(function(callback){
				var Ticket = new TicketModel();
				Ticket.lavado_id = reqTicket.lavado_id;
				Ticket.order_id = reqTicket.order_id;
				Ticket.corte_id = reqTicket.corte_id;
				Ticket.status = reqTicket.status;
				Ticket.user = reqTicket.user;
				Ticket.car.denomination = reqTicket.car.denomination;
				Ticket.car.price = Number(reqTicket.car.price);
				reqTicket.services.forEach(function(service){
					var tmp = {
						'denomination': service.denomination,
						'price': Number(service.price)
					}
					Ticket.services.push(tmp);
				});
				Ticket.services = reqTicket.services;
				Ticket.entryDate = reqTicket.entryDate;
				Ticket.exitDate = reqTicket.exitDate;
				Ticket.washingTime = reqTicket.washingTime;
				Ticket.total = reqTicket.total;
				Ticket.date = reqTicket.date;
				Ticket.save(function(err){
					if(err){
						callback(null,{'name':'tickets','_id':Ticket._id,'succesfull':false});
					}else{
						callback(null,{'name':'tickets','_id':Ticket._id,'succesfull':true});
					}
				});
			});
		});

		req.body.spends.forEach(function(reqSpend){
			Tasks.push(function(callback){
				var Spend = new SpendModel();
				Spend.lavado_id = reqSpend.lavado_id;
				Spend.corte_id = reqSpend.corte_id;
				Spend.denomination = reqSpend.denomination;
				Spend.total = reqSpend.total;
				if(reqSpend.isMonthly){
					Spend.isMonthly = reqSpend.isMonthly;
				}
				Spend.user = TokenObj.user_username;
				Spend.date = reqSpend.date;
				Spend.save(function(err){
					if(err){
						callback(null,{'name':'spends','_id':Spend._id,'succesfull':false});
					}else{
						callback(null,{'name':'spends','_id':Spend._id,'succesfull':true});
					}
				});
			});
		});

		req.body.ingresses.forEach(function(reqIngress){
			Tasks.push(function(callback){
				var Ingress = new IngressModel();
				Ingress.lavado_id = reqIngress.lavado_id;
				Ingress.corte_id = reqIngress.corte_id;
				Ingress.denomination = reqIngress.denomination;
				Ingress.total = reqIngress.total;
				Ingress.user = TokenObj.user_username;
				Ingress.date = reqIngress.date;
				Ingress.save(function(err){
					if(err){
						callback(null,{'name':'ingresses','_id':Ingress._id,'succesfull':false});
					}else{
						callback(null,{'name':'ingresses','_id':Ingress._id,'succesfull':true});
					}
				});
			});
		});

		req.body.paybills.forEach(function(reqPaybill){
			Tasks.push(function(callback){
				var Paybill = new PaybillModel();
				Paybill.lavado_id = reqPaybill.lavado_id;
				Paybill.corte_id = reqPaybill.corte_id;
				Paybill.denomination = reqPaybill.denomination;
				Paybill.total = reqPaybill.total;
				Paybill.user = TokenObj.user_username;
				Paybill.owner = reqPaybill.owner;
				Paybill.date = reqPaybill.date;
				Paybill.save(function(err){
					if(err){
						callback(null,{'name':'paybills','_id':Paybill._id,'succesfull':false});
					}else{
						callback(null,{'name':'paybills','_id':Paybill._id,'succesfull':true});
					}
				});
			});
		});

		req.body.cortes.forEach(function(reqCorte){
			Tasks.push(function(callback){
				var Corte = new CorteModel();
				Corte.lavado_id = reqCorte.lavado_id;
				Corte.corte_id = reqCorte.corte_id;
				Corte.user = reqCorte.user;
				Corte.date = reqCorte.date;
				Corte.save(function(err){
					if(err){
						callback(null,{'name':'cortes','_id':Corte._id,'succesfull':false});
					}else{
						callback(null,{'name':'cortes','_id':Corte._id,'succesfull':true});
					}
				});
			});
		});

		req.body.pendings.forEach(function(reqPending){
			Tasks.push(function(callback){
				var Pending = new PendingModel();
				Pending.date = reqPending.date;
				Pending.lavado_id = reqPending.lavado_id;
				Pending.user = reqPending.user_id;
				Pending.denomination = reqPending.denomination;
				Pending.corte_id = reqPending.corte_id;
				Pending.isDone = reqPending.isDone;

				Pending.save(function(err){
					if(err){
						callback(null,{'name':'pendings','_id':Pending._id,'succesfull':false});
					}else{
						callback(null,{'name':'pendings','_id':Pending._id,'succesfull':true});
					}
				});
			});
		});

		async.series(Tasks, function(err, Results) {
            if (err){
                console.log(err);
            }
			var arrayOfTicketsid = [];
			var arrayOfSpendsid = [];
			var arrayOfIngressid = [];
			var arrayOfBillsid = [];
			var arrayOfCortesid = [];
			var arrayOfPendingsid = [];

			Results.forEach(function(result){
				if(result.name == "tickets"){
					arrayOfTicketsid.push(result._id);
				}else if(result.name == "spends"){
					arrayOfSpendsid.push(result._id);
				}else if(result.name == "ingresses"){
					arrayOfIngressid.push(result._id);
				}else if(result.name == "paybills"){
					arrayOfBillsid.push(result._id);
				}else if(result.name == "cortes"){
					arrayOfCortesid.push(result._id);
				}else if(result.name == "pendings"){
					arrayOfPendingsid.push(result._id);
				}else{
				}
			});
			if(Results){
	    		res.json({
					success: true,
					tickets: arrayOfTicketsid,
					spends: arrayOfSpendsid,
					ingresses: arrayOfIngressid,
					paybills: arrayOfBillsid,
					cortes: arrayOfCortesid,
					pendings: arrayOfPendingsid,
					message:'Contenido Actualizado con el servidor.'
				});
			}else{
				res.json({success: false , message:'Ocurrio algun error.'});
			}
    	});
	},

	DeleteById: function(req,res){
		var Tasks = [];
		req.body.spends.forEach(function(spend_id){
			Tasks.push(function(callback){
				SpendModel.remove(
					{
						_id: spend_id
					},
					function(err,Spend){
						if(err){
							callback(null,false);
						}else{
							callback(null,true);
						}
					}
				);
			});
		});

		req.body.ingresses.forEach(function(ingress_id){
			Tasks.push(function(callback){
				IngressModel.remove(
					{
						_id: ingress_id
					},
					function(err,Ingress){
						if(err){
							callback(null,false);
						}else{
							callback(null,true);
						}
					}
				);
			});
		});

		req.body.paybills.forEach(function(paybill_id){
			Tasks.push(function(callback){
				PaybillModel.remove(
					{
						_id: paybill_id
					},
					function(err,Paybill){
						if(err){
							callback(null,false);
						}else{
							callback(null,true);
						}
					}
				);
			});
		});

		req.body.pendings.forEach(function(pending_id){
			Tasks.push(function(callback){
				PendingModel.remove(
					{
						_id: pending_id
					},
					function(err,Pending){
						if(err){
							callback(null,false);
						}else{
							callback(null,true);
						}
					}
				);
			});
		});

		async.series(Tasks, function(err, result) {
				if (err){
					console.log(err);
				}
				if(result){
					res.json({success: true , message: 'Todo Borrados.'});
				}else{
					res.json({success: false , message:'Ocurrio algun error.'});
				}
		});
	}
}
