require 'sketchup.rb'
require 'json'

submenu  = UI.menu("Plugins").add_submenu( "Rexplus order" )

submenu.add_item("Export to *.rex") {
	modelPath = Sketchup.active_model.path
	filename = File.basename(modelPath, '.*')
	filename += ".rex"
	dest = UI.savepanel("Save Rex-Plus Order", "D:\\", filename)
	
	customer = getCustomer()
	
	saveOrder( dest, getTetelek, customer["name"], customer["phone"], customer["email"] )
}

submenu.add_item("Export to JSON") {
	tetelek = getTetelek()
	
	tetelek_json = "{\\\"Tetelek\\\":["
	first = true
	for tetel in tetelek
		tetelek_json += "," unless first
		tetelek_json += "{\\\"name\\\":\\\"#{tetel.name}\\\","
		tetelek_json += "\\\"hossz\\\":\\\"#{tetel.hossz}\\\","
		tetelek_json += "\\\"szel\\\":\\\"#{tetel.szel}\\\","
		tetelek_json += "\\\"darab\\\":\\\"#{tetel.darab}\\\","
		tetelek_json += "\\\"blap\\\":\\\"#{tetel.blap}\\\","
		tetelek_json += "\\\"folia_tipus\\\":\\\"#{tetel.folia_tipus}\\\","
		tetelek_json += "\\\"abs_tipus\\\":\\\"#{tetel.abs_tipus}\\\","
		tetelek_json += "\\\"folia\\\":\\\"#{tetel.folia}\\\","
		tetelek_json += "\\\"abs\\\":\\\"#{tetel.abs}\\\"}"
		tetelek_json += "\\\"megjegyzes\\\":\\\"#{tetel.megjegyzes}\\\"}"
		first = false if first
	end
	tetelek_json += "]}"
	
	dlg = UI::WebDialog.new( "Specify details of the order", "", false, 500, 300, 433, 234, false )
	js_command = "document.getElementById('data').innerHTML = '#{tetelek_json}'"
	
	dlg.set_file( File.dirname(__FILE__) + '/rexplus_order/html/rexplus.html' )
	dlg.add_action_callback( "closeDialog" ) {|dialog, params|
		data = dlg.get_element_value( "data" )
		puts data
		dlg.close
	}
	dlg.show {
		dlg.execute_script( "document.getElementById('data').innerHTML = 'Hello World!'" )
	}	
}

submenu.add_item("Set personal data") {
	file = open( File.dirname(__FILE__) + '/rexplus_order/cust.json', "r" )
	json = file.read
	file.close
	
	custData = JSON.parse( json )
	customer = custData["customer"][0]

	prompts = [ "Name:", "Phone:", "Email:" ]
	defaults = [ customer["name"], customer["phone"], customer["email"] ]
	title = "Save personal data"
	
	input = UI.inputbox( prompts, defaults, title )
	
	if(input)
		customer["name"]  = input[0]
		customer["phone"] = input[1]
		customer["email"] = input[2]
	
		file = open( File.dirname(__FILE__) + '/rexplus_order/cust.json', "w+" )
		file.write( custData.to_json )
		file.close
	end
}

submenu.add_item("Help") {
	dlg = UI::WebDialog.new( "Help", "", false, 570, 240, 428, 304, false )
	
	dlg.set_file( File.dirname(__FILE__) + '/rexplus_order/html/help.html' )
	dlg.show
}

def getCustomer()
	file = open( File.dirname(__FILE__) + '/rexplus_order/cust.json', "r" )
	json = file.read
	file.close
	
	custData = JSON.parse( json )
	return custData["customer"][0]
end

def getDimensions( bounds )
	width = bounds.width.to_s.sub!(/,\d\D*/, "").to_i
	height = bounds.height.to_s.sub!(/,\d\D*/, "").to_i
	depth = bounds.depth.to_s.sub!(/,\d\D*/, "").to_i
	meretek = [ width, height, depth ]
	meretek.delete( 18 )
	meretek.delete( 3 )
	meretek.sort!.reverse!
	return meretek
end

def getTetelek( )
	tetelek = []
    definitions = Sketchup.active_model.definitions
    for definition in definitions
        if( isTetel( definition ) )
			next if (definition.description =~ /skip/)
            meretek = getDimensions( definition.bounds )
			tetel = Tetel.new( definition.name, meretek[0], meretek[1], definition.count_instances, definition.name )
			tetel.setAttr( definition.description )
			tetelek << tetel
        end
    end
    return tetelek
end

def isTetel( componentDefinition )
    for entity in componentDefinition.entities
        if( entity.typename == "ComponentInstance" )
            return false
        end
    end
    return true
end

def saveOrder( destination, tetelek, nev = "", telefon = "", email = "" )
	orderXml = File.new( destination, "w+" )
	orderXml.syswrite( "<rendeles><tetelek>" )
	for tetel in tetelek
		orderXml.syswrite( tetel.toString() )
	end
	orderXml.syswrite( "</tetelek><adatok><nev>#{nev}</nev><cegnev /><telefon>#{telefon}</telefon><email>#{email}</email></adatok></rendeles>" )
	orderXml.close
end

class Tetel

    def initialize( name, hossz, szel, darab, blap = "2711", folia_tipus = "-1", abs_tipus = "-1", folia = "00", abs = "00", megjegyzes = "" )
        @name=name
		@hossz=hossz
        @szel=szel
        @darab=darab
        @blap=blap
        @folia_tipus=folia_tipus
        @abs_tipus=abs_tipus
        @folia=folia
        @abs=abs
        @megjegyzes=megjegyzes
    end

    attr_reader :name
    attr_reader :hossz
    attr_reader :szel
    attr_reader :darab
    attr_reader :blap
    attr_reader :folia_tipus
    attr_reader :abs_tipus
    attr_reader :folia
    attr_reader :abs
    attr_reader :megjegyzes

    def toString
        return "<tetel>"\
			   "<hossz>#{@hossz}</hossz>"\
			   "<szel>#{@szel}</szel>"\
			   "<darab>#{@darab}</darab>"\
			   "<blap_tipus>#{@blap}</blap_tipus>"\
			   "<folia_tipus>#{@folia_tipus}</folia_tipus>"\
			   "<abs_tipus>#{@abs_tipus}</abs_tipus>"\
			   "<folia>#{@folia}</folia>"\
			   "<abs>#{@abs}</abs>"\
			   "<megjegyzes><![CDATA[#{@megjegyzes}]]></megjegyzes>"\
			   "</tetel>"
    end
	
	def setAttr( description )
		attr_set = false
		for line in description.split('\n')
			if( line =~ /melamine\s+=\s+([0-9]{4})/ )
				@blap = $1
				attr_set = true
			end
			if( line =~ /foilType\s+=\s+([0-9]{3})/ )
				@folia_tipus = $1
			end
			if( line =~ /absType\s+=\s+([0-9]{3})/ )
				@abs_tipus = $1
			end
			if( line =~ /foilProfile\s+=\s+([0-9]{2})/ )
				@folia = $1
			end
			if( line =~ /absProfile\s+=\s+([0-9]{2})/ )
				@abs = $1
			end
		end
		return attr_set
	end
end