//MODELS
var TicketModel = require("../models/ticket");
var UserModel = require("../models/user");

var mongoose = require("mongoose");
var moment = require("moment");
var async = require("async");

var Schema = mongoose.Schema;


module.exports = {

	AddNewTicket: function(req,res){

		var TokenObj = req.decoded;
		var Ticket = new TicketModel();
		//se rellenan los campos
		Ticket.lavado_id = req.body.lavado_id;
		Ticket.order_id = req.body.order_id;
		Ticket.corte_id = req.body.corte_id;
		Ticket.status = req.body.status;
		Ticket.user = req.body.user;

		Ticket.car.denomination = req.body.car.denomination;
		Ticket.car.price = Number(req.body.car.price);

		req.body.services.forEach(function(service){
			var tmp = {
				'denomination': service.denomination,
				'price': Number(service.price)
			}
			Ticket.services.push(tmp);
		});

		Ticket.services = req.body.services;
		Ticket.entryDate = req.body.entryDate;
		Ticket.exitDate = req.body.exitDate;
		Ticket.washingTime = req.body.washingTime;
		Ticket.total = req.body.total;
		Ticket.date = req.body.date;

		Ticket.save(function(err){
			if(err){
				return res.json({success:false,error:err});
			}
			res.json({success: true , message:"Ticket Agregado Exitosamente."});
		});
	},

	AllTickets: function(req,res){

		var TokenObj = req.decoded;
		if (TokenObj.rol == "SuperAdministrador") {

			TicketModel.find( function(err, Tickets) {

				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , tickets:Tickets});
			});

		}else{
			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}
	},

	AllTicketsByLavado: function(req,res) {
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
		TicketModel.paginate(Query,Paginator, function(err, result) {
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , tickets: result});
		});
	},


	AllTicketsByAccount: function(req,res) {

		var TokenObj = req.decoded;

		if (TokenObj.rol == "SuperAdministrador") {

			if(req.body.initialDate && req.body.finalDate){

				TicketModel.find(
				{
					date: {
				      	$gte: moment(req.body.initialDate),
				      	$lt: moment(req.body.finalDate)
				    }
				}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Tickets){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , tickets:Tickets});
				});
			}else{
				var initialDate = moment().format('YYYY-MM-DD');
				var finalDate = moment().add(1,'day').format('YYYY-MM-DD');

				TicketModel.find(
				{
					date: {
				      	$gte: initialDate,
				      	$lt: finalDate
				    }
				}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Tickets){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , tickets:Tickets});
				});
			}

		}else{

			UserModel.findById(req.params.user_id, function(err, Usuario){
				if(err){
					res.json({success:false,error:err});
				}
				var Return = [];
				var Tasks = [];

				Usuario.lavado_id.forEach(function(carwash){
					Tasks.push(function(callback){

						if(req.body.initialDate && req.body.finalDate){

							TicketModel.find(
							{
								lavado_id: carwash,
								date: {
							      	$gte: moment(req.body.initialDate),
							      	$lt: moment(req.body.finalDate)
							    }
							}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Tickets){
								if(err){
									res.json({success:false,error:err});
								}
								callback(null,Tickets);
							});

						}else{

							var initialDate = moment().format('YYYY-MM-DD');
							var finalDate = moment().add(1,'day').format('YYYY-MM-DD');

							TicketModel.find(
							{
								lavado_id: carwash,
								date: {
							      	$gte: initialDate,
							      	$lt: finalDate
							    }
							}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Tickets){
								if(err){
									res.json({success:false,error:err});
								}
								callback(null,Tickets);
							});
						}
	                });
		    	});

				async.series(Tasks, function(err, result) {
	                    if (err){
	                        console.log(err);
	                    }
						result.forEach(function(obj){
							obj.forEach(function(objToReturn){
								Return.push(objToReturn);
							});
						});
						if(Return){
				    		res.json({success: true , tickets:Return});
						}else{
							res.json({success: false , message:'Ocurrio algun error.'});
						}
	            });
			});
		}
	},

	SearchTicketById: function(req,res){
		TicketModel.findById( req.params.ticket_id, function(err,Ticket){
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , ticket:Ticket});

		});
	},

	UpdateTicketById: function(req,res){

		TicketModel.findById( req.params.ticket_id, function(err, Ticket){
			//some error
			if(err){
				res.json({success:false,error:err});
			}


			//se rellenan los campos
			if(req.body.lavado_id){
				Ticket.lavado_id = req.body.lavado_id;
			}
			if(req.body.order_id){
				Ticket.order_id = req.body.order_id;
			}
			if(req.body.corte_id){
				Ticket.corte_id = req.body.corte_id;
			}
			if(req.body.user){
				Ticket.user = req.body.user;
			}
			if(req.body.car){
				Ticket.car = req.body.car;
			}
			if(req.body.user){
				Ticket.services = req.body.services;
			}
			if(req.body.services){
				Ticket.exitDate = req.body.exitDate;
			}
			if(req.body.washingtime){
				Ticket.washingtime = req.body.washingtime;
			}
			if(req.body.total){
				Ticket.total = req.body.total;
			}
			if(req.body.date){
				Ticket.date = req.body.date;
			}
			//Salvar el usuario actualizado en la DB.
			Ticket.save(function(err){
				if(err){
					res.send(err);
				}
				res.json({success: true , message:"Ticket Actualizado Exitosamente."});
			});
		});

	},

	DeleteTicketById: function(req,res){

		TicketModel.remove(
			{
				_id: req.params.ticket_id
			},
			function(err,Ticket){
				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , message:"Ticket Borrado Exitosamente."});
			}
		);
	},

}
