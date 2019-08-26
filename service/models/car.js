
var mongoose = require("mongoose");
var Schema = mongoose.Schema;


var AutoSchema = new Schema({

	lavado_id: {
		type: Schema.ObjectId,
		ref: 'Carwash',
		required: true
	},
	denomination:{
		type: String,
		default: "Sin Descripcion",
		required: true
	},
	price:{
		type: Number,
		default: 0.00
	},
	img:{
		type: String,
		default: "CARRO.png"
	},
    created: {
        type: Date,
        default: Date.now()
    }

});



//Return the module
module.exports = mongoose.model("Car",AutoSchema);
