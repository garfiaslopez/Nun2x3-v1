//MODELS
var PendingModel = require("../models/pending");

module.exports = {

	Create: function(req,res){
		var Pending = new PendingModel();
		Pending.date = req.body.date;
		Pending.lavado_id = req.body.lavado_id;
		Pending.user = req.body.user;
		Pending.denomination = req.body.denomination;
		Pending.corte_id = req.body.corte_id;

		Pending.save(function(err){
			if(err){
				return res.json({success:false,error:err});
			}
			res.json({success: true , message:"Pendiente Agregado Exitosamente.", _id: Pending._id});
		});
	},

	All: function(req,res){
		PendingModel.find( function(err, Pendings) {
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , pendings: Pendings});
		});
	},

	AllByLavado: function(req,res){
		PendingModel.find({lavado_id: req.params.lavado_id, isDone: false}).exec(function(err,Pendings){
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , pendings:Pendings});
		});
	},

	ById: function(req,res){
		PendingModel.findById( req.params.pending_id, function(err, Pending){
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , pending: Pending});
		});
	},

	Update: function(req,res){
		PendingModel.findById( req.params.pending_id, function(err, Pending){
			if(err){
				res.json({success:false,error:err});
			}
			if(req.body.date){
				Pending.date = req.body.date;
			}
			if(req.body.lavado_id){
				Pending.lavado_id = req.body.lavado_id;
			}
			if(req.body.user){
				Pending.user = req.body.user;
			}
			if(req.body.denomination){
				Pending.denomination = req.body.denomination;
			}
			if(req.body.corte_id){
				Pending.corte_id = req.body.corte_id;
			}
			if(req.body.isDone){
				Pending.isDone = req.body.isDone;
			}
			Pending.save(function(err){
				if(err){
					return res.json({success:false,error:err});
				}
				res.json({success: true , message:"Pendiente Actualizado Exitosamente."});
			});
		});
	},

	Delete: function(req,res){
		PendingModel.remove(
			{
				_id: req.params.pending_id
			},
			function(err,Product){
				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , message:"Pendiente Borrado Satisfactoriamente"});
			}
		);
	},


}
