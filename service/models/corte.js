var mongoose = require("mongoose");
var Schema = mongoose.Schema;

var CorteSchema = new Schema({

	lavado_id: {
		type: Schema.ObjectId,
		ref: 'Carwash',
		required: true
	},
	corte_id:{
		type: String
	},
	user:{
		type: String
	},
	countTickets: {
		type: Number
	},
	totalTickets: {
		type: Number
	},
	countSpends: {
		type: Number
	},
	totalSpends: {
		type: Number
	},
	countIngresses: {
		type: Number
	},
	totalIngresses: {
		type: Number
	},
	countPaybills: {
		type: Number
	},
	totalPaybills: {
		type: Number
	},
	date:{
		type: Date
	},
	created: {
		type: Date,
		default: Date.now
	}
});

//Return the module
module.exports = mongoose.model("Corte",CorteSchema);
