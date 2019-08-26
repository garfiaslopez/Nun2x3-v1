//PACKAGES:
var mongoose = require("mongoose");
var Schema = mongoose.Schema;
var bcrypt = require("bcrypt-nodejs");

//USER SCHEMA:
//index unique attributte dice que ningun usuario podra ser duplicado, sera unico,
//required es que es un attributo requerido
//select indica que no necesariamente se regresa ese attributo al momento de enlistar los documentos pedidos (proteccion)

var UserSchema = new Schema({
	lavado_id: [{
		type: Schema.ObjectId,
		ref: 'Carwash',
		required: true
	}],
	username: {
		type: String,
		trim: true,
		required: true,
        unique: true
	},
	password: {
		type: String,
		required: true
	},
	rol: {
		type: String,
		default:"Empleado",
		required: true,
	},
	push_id: {
		type: String,
		default: ""
	},
	info:{
		name: {type: String, default: "Sin Nombre"},
		phone: {type: String, default: "Sin Numero Telefonico"},
		address: {type: String, default: "Sin Direccion"}
	},
    created: {
        type: Date,
        default: Date.now
    }

});
//
// //HASH THE PASSWORD USER BEFORE IS SAVED:
// function hashPassword(next){
//
// 	var user = this;
//
// 	//hash only if the user is new or have been modified.
// 	if(!user.isModified("password")){
// 		return next();
// 	}
//
// 	bcrypt.hash(user.password, null, null, function(err,hash){
//
// 		if(err){
// 			return next(err);
// 		}
//
// 		user.password = hash;
// 		next();
// 	})
// }
//
// UserSchema.pre("save", hashPassword);
//
// function isEqualPassword(password){
// 	var user = this;
// 	return bcrypt.compareSync(password,user.password);
// }
//
// UserSchema.methods.comparePassword = isEqualPassword;


//Return the module
module.exports = mongoose.model("User",UserSchema);
