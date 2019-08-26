//MODELS
var UserModel = require("../models/user");
//JSONWEBTOKEN
var jwt = require("jsonwebtoken");
//Config File
var Config = require("../config/config");
var KeyToken = Config.key;
var mongoose = require("mongoose");
var ObjectId = mongoose.Types.ObjectId;

module.exports = {
	AuthByUser: function(req,res){
		UserModel.findOne({
				username: req.body.username,
				password: req.body.password
			}).populate("lavado_id").exec( function(err, Usuario){
				if(err){
					res.json({success:false,error:err});
				}
				if(!Usuario){
					res.json({success:false,message:"Usuario o Contraseña incorrectos."});
				}else{
					var token = jwt.sign(
						{
							lavado_id: Usuario.lavado_id,
							user_id: Usuario._id,
							user_username: Usuario.username,
							rol: Usuario.rol
						},
						KeyToken,
						{
							expiresIn: 2880
						}
					);
					res.json({success:true,message:"Logueado Corectamente.",token:token,user:Usuario});
				}
			}
		);
	},

	InfoUser: function(req,res){
		var userId = new ObjectId(req.decoded.user_id);
		UserModel.findOne({_id:userId}).exec(function(err,Usuario){
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , user:Usuario});
		});
	}
}
