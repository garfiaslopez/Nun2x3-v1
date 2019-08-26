//MODELS
var IngressModel = require("../models/ingress");

var mongoose = require("mongoose");
var moment = require("moment");

var Schema = mongoose.Schema;
var ObjectId = mongoose.Types.ObjectId;


module.exports = {

	AddNewIngress: function(req,res){

		var TokenObj = req.decoded;
		var Ingress = new IngressModel();

		//se rellenan los campos
		Ingress.lavado_id = req.body.lavado_id;
		Ingress.corte_id = req.body.corte_id;
		Ingress.denomination = req.body.denomination;
		Ingress.total = req.body.total;

		//se asigna el usuario del token
		Ingress.user = TokenObj.user_username;
		Ingress.date = req.body.date;

		Ingress.save(function(err){

			if(err){
				return res.json({success:false,error:err});
			}

			res.json({success: true , message:"Ingreso Agregado Exitosamente.", _id: Ingress._id});
		});
	},

	AllIngresses: function(req,res){

		var TokenObj = req.decoded;
		if (TokenObj.rol == "SuperAdministrador") {

			IngressModel.find( function(err, Ingresses) {

				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , ingresses:Ingresses});
			});

		}else{
			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}



	},

	AllIngressesByLavado: function(req,res) {
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
		IngressModel.paginate(Query,Paginator, function(err, result) {
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , ingresses: result});
		});
	},


	AllIngressesByAccount: function(req,res) {

		var TokenObj = req.decoded;

		if (TokenObj.rol == "SuperAdministrador") {

			if(req.body.initialDate && req.body.finalDate){

				IngressModel.find(
				{
					date: {
				      	$gte: moment(req.body.initialDate),
				      	$lt: moment(req.body.finalDate)
				    }
				}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Ingresses){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , ingresses:Ingresses});
				});
			}else{
				var initialDate = moment().format('YYYY-MM-DD');
				var finalDate = moment().add(1,'day').format('YYYY-MM-DD');

				IngressModel.find(
				{
					date: {
				      	$gte: initialDate,
				      	$lt: finalDate
				    }
				}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Ingresses){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , ingresses:Ingresses});
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

							IngressModel.find(
							{
								date: {
							      	$gte: moment(req.body.initialDate),
							      	$lt: moment(req.body.finalDate)
							    }
							}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Ingresses){
								if(err){
									res.json({success:false,error:err});
								}
								callback(null,Ingresses);
							});
						}else{
							var initialDate = moment().format('YYYY-MM-DD');
							var finalDate = moment().add(1,'day').format('YYYY-MM-DD');

							IngressModel.find(
							{
								date: {
							      	$gte: initialDate,
							      	$lt: finalDate
							    }
							}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Ingresses){
								if(err){
									res.json({success:false,error:err});
								}
								callback(null,Ingresses);
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
				    		res.json({success: true , ingresses:Return});
						}else{
							res.json({success: false , message:'Ocurrio algun error.'});
						}
	            });
			});
		}
	},

	SearchIngressById: function(req,res){
		IngressModel.findById( req.params.ingress_id, function(err,Ingress){
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , ingress:Ingress});
		});
	},



	UpdateIngressById: function(req,res){
		IngressModel.findById( req.params.ingress_id, function(err, Ingress){
			//some error
			if(err){
				res.json({success:false,error:err});
			}
			//se rellenan los campos
			if(req.body.denomination){
				Ingress.denomination = req.body.denomination;
			}
			if(req.body.corte_id){
				Ingress.corte_id = req.body.corte_id;
			}
			if(req.body.total){
				Spend.total = req.body.total;
			}

			//Salvar el usuario actualizado en la DB.
			Ingress.save(function(err){
				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , message:"Ingreso Actualizado Exitosamente."});
			});
		});

	},

	DeleteIngressById: function(req,res){

		IngressModel.remove(
			{
				_id: req.params.ingress_id
			},
			function(err,Ingress){
				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , message:"Ingreso Borrado Exitosamente."});
			}
		);
	},

}
