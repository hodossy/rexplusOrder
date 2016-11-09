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
	
	customer["name"]  = input[0]
	customer["phone"] = input[1]
	customer["email"] = input[2]
	
	file = open( File.dirname(__FILE__) + '/rexplus_order/cust.json', "w+" )
	file.write( custData.to_json )
	file.close
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
			next if (definition ~= /skip/)
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