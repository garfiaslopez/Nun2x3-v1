var mongoose = require("mongoose");
var Schema = mongoose.Schema;

//DATE y CREATED SE GUARDA EN FORMATO ISO.
var ContactSchema = new Schema({
	lavado_id: {
		type: Schema.ObjectId,
		ref: 'Carwash',
		required: true
	},
	name: {
		type: String,
		trim: true,
		required: true,
	},
	phone: {
		type: Number,
		required: true,
		default: 0.00
	},
	address: {
		type: String
	},
    description: {
        type: String
    },
    created: {
        type: Date,
        default: Date.now
    }
});

//Return the module
module.exports = mongoose.model("Contact",ContactSchema);
