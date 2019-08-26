//MODELS
var UserModel = require("../models/user");
var LavadoModel = require("../models/carwash");

var jwt = require("jsonwebtoken");
var Config = require("./../config/config");
var KeyToken = Config.key;

var mongoose = require("mongoose");
var Schema = mongoose.Schema;
var async = require('async');
var _ = require('lodash');


module.exports = {

	AddNewUser: function(req,res){

		var TokenObj = req.decoded;
		var user = new UserModel();

		user.username = req.body.username;
		user.password = req.body.password;

		user.info.name = req.body.name;
		user.info.phone = req.body.phone;
		user.info.address = req.body.address;

		if (TokenObj.rol == "SuperAdministrador") {
			if(req.body.rol){
				user.rol = req.body.rol;
			}
		}

		req.body.lavado_id.forEach(function(carwash){
        	user.lavado_id.push(carwash);
    	});

		user.save(function(err){
			if(err){
				if(err.code == 11000){
					return res.json({success: false , message: "Ya existe ese nombre de usuario."});
				}else{
					return res.json({success:false,error:err});
				}
			}

			req.body.lavado_id.forEach(function(carwash){
	        	LavadoModel.findById(carwash, function(err, Lavado){
					if(err){
						res.json({success:false,error:err});
					}
					Lavado.users.push(user);
					Lavado.save(function(err){
						if(err){
							res.json({success:false,error:err});
						}
					});
				});
	    	});

			res.json({success: true , message:"Usuario Agregado Exitosamente."});
		});
	},

	AllUsers: function(req,res){

		var TokenObj = req.decoded;
		if (TokenObj.rol == "SuperAdministrador") {

			UserModel.find().exec(function(err, Usuarios) {

				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , users:Usuarios});
			});

		}else{
			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}



	},

	AllUsersByLavado: function(req,res) {
		UserModel.find(
			{
				lavado_id: req.params.lavado_id
			},

			function(err,Usuarios){
				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , users:Usuarios});
			}
		);
	},

	AllUsersByLavadoWithToken: function(req,res) {
		UserModel.find(
			{
				lavado_id: req.params.lavado_id
			},

			function(err,Usuarios){
				if(err){
					res.json({success:false,error:err});
				}
				var usersToReturn = [];
				Usuarios.forEach(function(user){

					var token = jwt.sign(
						{
							lavado_id: user.lavado_id,
							user_id: user._id,
							user_username: user.username,
							rol: user.rol
						},
						KeyToken,
						{
							expiresIn: 2880
						}
					);

					var NewUser = {
						user: user,
						token: token
					};
					usersToReturn.push(NewUser);
				});
				res.json({success: true , users:usersToReturn});
			}
		);
	},


	AllUsersByAccount: function(req,res) {

		UserModel.findById(req.params.user_id, function(err, Usuario){
			if(err){
				res.json({success:false,error:err});
			}

			var UsersToReturn = [];
			var GetUsersTasks = [];

			Usuario.lavado_id.forEach(function(carwash){
				GetUsersTasks.push(function(callback){
	 				LavadoModel.findById(carwash).populate('users').exec( function(err,Lavado){
						if(err){
							res.json({success:false,error:err});
						}

						var newusers = [];
						_.map(Lavado.users,function(user){

							var carwashesnames = [];
							_.map(user.lavado_id,function(carwash_id){
								LavadoModel.findById(carwash_id).exec( function(err,_carwash){
									carwashesnames.push(_carwash.info.name)
								});
							})

							var tmp = user.toObject();
							tmp.lavado_id = carwashesnames;
							newusers.push(tmp);
						});

						var tmpLavado = Lavado.toObject();
						tmpLavado.users = newusers;
						callback(null, tmpLavado);
					});
                });
	    	});

			async.series(GetUsersTasks, function(err, result) {
                    if (err){
                        console.log(err);
                    }

					_.map(result,function(carwash){
						_.map(carwash.users,function(user){
							user.lavado_name = carwash.info.name;
							UsersToReturn.push(user);
						});
					});

					UsersToReturn = _.uniq(UsersToReturn,'username');

					if(UsersToReturn){
			    		res.json({success: true , users:UsersToReturn});
					}else{
						res.json({success: false , message:'Ocurrio algun error.'});
					}
            });
		});
	},

	SearchUserById: function(req,res){
		UserModel.findById( req.params.user_id, function(err,Usuario){
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , user:Usuario});
		});
	},

	UpdateUserById: function(req,res){
		if(req.body.push_id) {
			UserModel.findById( req.params.user_id, function(err, Usuario){
				//some error
				if(err){
					res.json({success:false,error:err});
				}
				Usuario.push_id = req.body.push_id;
				Usuario.save(function(err){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , message:"Usuario Actualizado Exitosamente."});
				});
			});

		}else{
			var TokenObj = req.decoded;
			UserModel.findById( req.params.user_id, function(err, Usuario){
				//some error
				if(err){
					res.json({success:false,error:err});
				}
				if (req.body.username){
					Usuario.username = req.body.username;
				}
				if(req.body.password){
					Usuario.password = req.body.password;
				}
				if(req.body.name){
					Usuario.info.name = req.body.name;
				}
				if(req.body.phone){
					Usuario.info.phone = req.body.phone;
				}
				if(req.body.address){
					Usuario.info.address = req.body.address;
				}
				if(req.body.push_id){
					Usuario.push_id = req.body.push_id;
				}
				if (TokenObj.rol == "SuperAdministrador") {
					if(req.body.rol){
						Usuario.rol = req.body.rol;
					}
				}
				var DeleteUserTasks = [];
				Usuario.lavado_id.forEach(function(carwash){
					DeleteUserTasks.push(function(callback){
		        		LavadoModel.findById(carwash, function(err, Lavado){
							if(err){
								res.json({success:false,error:err});
							}
	                        var x = _.findIndex(Lavado.users, Usuario._id);
	                        Lavado.users.splice(x,1);
		                    Lavado.save(function(err){
								if(err){
									res.json({success:false,error:err});
								}
								callback(null, '1');
							});
						});
	                });
		    	});

				async.series(DeleteUserTasks, function(err, result) {
	                if (err){
	                    console.log(err);
	                }

					req.body.lavado_id.forEach(function(carwash){
			        	LavadoModel.findById(carwash, function(err, Lavado){
							if(err){
								res.json({success:false,error:err});
							}
							Lavado.users.push(Usuario);
							Lavado.save(function(err){
								if(err){
									res.json({success:false,error:err});
								}
							});
						});
			    	});

	                Usuario.lavado_id = [];
	                Usuario.lavado_id = req.body.lavado_id;

					Usuario.save(function(err){
						if(err){
							res.json({success:false,error:err});
						}
						res.json({success: true , message:"Usuario Actualizado Exitosamente."});
					});
	            });
			});

		}
	},


	DeleteUserById: function(req,res){

		UserModel.findById( req.params.user_id, function(err, Usuario){

			var DeleteUserTasks = [];
			Usuario.lavado_id.forEach(function(carwash){
				DeleteUserTasks.push(function(callback){
	        		LavadoModel.findById(carwash, function(err, Lavado){
						if(err){
							res.json({success:false,error:err});
						}
	                    var x = _.findIndex(Lavado.users, Usuario._id);
	                    Lavado.users.splice(x,1);
	                    Lavado.save(function(err){
							if(err){
								res.json({success:false,error:err});
							}
							callback(null, '1');
						});
					});
	            });
	    	});

			async.series(DeleteUserTasks, function(err, result) {
                if (err){
                    console.log(err);
                }
				UserModel.remove(
					{
						_id: req.params.user_id
					},
					function(err,Usuario){
						if(err){
							res.json({success:false,error:err});
						}
						res.json({success: true , message:"Usuario Borrado Exitosamente."});
					}
				);
            });

		});
	},

	InfoUserByToken: function(req,res){
		res.send(req.decoded);
	}


}
