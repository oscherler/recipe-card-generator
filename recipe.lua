-- Example “Extracting information about links” is wrong
-- Example “Creating a handout from a paper” is right
function Pandoc( doc )
	local currentSection = {}
	local currentClasses = {}
	local newDoc = {}

	-- if you don’t use pairs(), it loops over some huge shit
	for i, block in pairs( doc.blocks ) do
		-- wrap content delimited by H1s in section (div of class section, that Pandoc turns into section)
		if block.t == 'Header' and block.level == 1 then
			if #currentSection > 0 then
				-- add section to current classes
				table.insert( currentClasses, 'section' )
				-- add content of current section to document
				table.insert( newDoc, pandoc.Div( currentSection, pandoc.Attr( '', currentClasses, {} ) ) )
			end
			
			-- start a new section
			currentSection = {}
			-- save header classes to set on section
			currentClasses = block.classes
			
			-- remove classes from header
			block.classes = {}
		end

		-- insert block into current section
		table.insert( currentSection, block )
	end

	if #currentSection > 0 then
		-- add section to current classes
		table.insert( currentClasses, 'section' )
		-- add content of current section to document
		table.insert( newDoc, pandoc.Div( currentSection, pandoc.Attr( '', currentClasses, {} ) ) )
	end

	-- output modified document
	return pandoc.Pandoc( newDoc, doc.meta )
end
