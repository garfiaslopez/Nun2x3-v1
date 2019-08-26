//MODELS
var ActiveTicketModel = require("../models/activeticket");
var UserModel = require("../models/user");

var mongoose = require("mongoose");
var moment = require("moment");
var async = require("async");

var Schema = mongoose.Schema;


module.exports = {

	AddNewActiveTicket: function(req,res){

		var TokenObj = req.decoded;
		var ActiveTicket = new ActiveTicketModel();

		//se rellenan los campos
		ActiveTicket.lavado_id = req.body.lavado_id;
		ActiveTicket.indexpath = req.body.indexpath;
		ActiveTicket.order_id = req.body.order_id;

		ActiveTicket.save(function(err){
			if(err){
				return res.json({success:false,error:err});
			}
			res.json({success: true , message:"Ticket Agregado Exitosamente.", ticket_id: ActiveTicket._id});
		});
	},

	AllActiveTickets: function(req,res){
		var TokenObj = req.decoded;
		if (TokenObj.rol == "SuperAdministrador") {
			ActiveTicketModel.find( function(err, Tickets) {
				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , activetickets:Tickets});
			});
		}else{
			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}
	},

	AllActiveTicketsByLavado: function(req,res) {
		ActiveTicketModel.find({
			lavado_id: req.params.lavado_id
		}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Tickets){
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , activetickets:Tickets});
		});
	},

	AllActiveTicketsByAccount: function(req,res) {

		var TokenObj = req.decoded;
		if (TokenObj.rol == "SuperAdministrador") {
			if(req.body.initialDate && req.body.finalDate){
				ActiveTicketModel.find(
				{
					date: {
				      	$gte: moment(req.body.initialDate),
				      	$lt: moment(req.body.finalDate)
				    }
				}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Tickets){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , activetickets:Tickets});
				});
			}else{
				var initialDate = moment().format('YYYY-MM-DD');
				var finalDate = moment().add(1,'day').format('YYYY-MM-DD');
				ActiveTicketModel.find(
				{
					date: {
				      	$gte: initialDate,
				      	$lt: finalDate
				    }
				}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Tickets){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , activetickets:Tickets});
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

							ActiveTicketModel.find(
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

							ActiveTicketModel.find(
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
				    		res.json({success: true , activetickets:Return});
						}else{
							res.json({success: false , message:'Ocurrio algun error.'});
						}
	            });
			});
		}

	},

	SearchActiveTicketById: function(req,res){
		ActiveTicketModel.findById( req.params.ticket_id, function(err,Ticket){
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , activeticket:Ticket});

		});
	},

	UpdateActiveTicketById: function(req,res){
		ActiveTicketModel.findById( req.params.ticket_id, function(err, Ticket){
			//some error
			if(err){
				res.json({success:false,error:err});
			}
			//se rellenan los campos
			if(req.body.lavado_id){
				Ticket.lavado_id = req.body.lavado_id;
			}
			if(req.body.indexpath){
				Ticket.indexpath = req.body.indexpath;
			}
			Ticket.save(function(err){
				if(err){
					res.send(err);
				}
				res.json({success: true , message:"Ticket Actualizado Exitosamente."});
			});
		});
	},

	DeleteActiveTicketById: function(req,res){
		ActiveTicketModel.remove(
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

	DeleteActiveTicketsByLavado: function(req,res){
		ActiveTicketModel.remove(
			{
				lavado_id: req.params.lavado_id
			},
			function(err,Ticket){
				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , message:"Tickets Borrado Exitosamente."});
			}
		);
	},


	DeleteActiveTicketByIndex: function(req,res){
		ActiveTicketModel.remove(
			{
				lavado_id: req.params.lavado_id,
				indexpath: req.params.indexpath
			},
			function(err,Ticket){
				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , message:"Ticket Borrado Exitosamente."});
			}
		);
	}
}
