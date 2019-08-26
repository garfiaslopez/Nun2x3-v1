var mongoose = require("mongoose");
var Schema = mongoose.Schema;

var ActiveTicketSchema = new Schema({

	lavado_id: { 
		type: Schema.ObjectId, 
		ref: 'Carwash',
		required: true 
	},
	indexpath:{
		type: Number
	},
	order_id:{
		type: String
	},
	date: {
		type: Date
	},
	created: {
		type: Date,
		default: Date.now
	}
	
});

//Return the module
module.exports = mongoose.model("ActiveTicket",ActiveTicketSchema);