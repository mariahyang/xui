require 'xdb'
xdb.bind(xtra.dbh)

m_modules = {}


function find_all()
	return xdb.find_by_cond('params', {realm = 'modules'})
end

function toggle_param(param_id)
	sql = "UPDATE params SET disabled = NOT disabled" ..
		xdb.cond({realm = 'modules', id = param_id})
	print(sql)
	xdb.execute(sql)
	if xdb.affected_rows() == 1 then
		return xdb.find("params", param_id)
	end
	return nil
end

function update_param(param_id, kvp)
	xdb.update_by_cond("params", {realm = 'modules',id = param_id}, kvp)
	if xdb.affected_rows() == 1 then
		return xdb.find("params", param_id)
	end
	return nil;
end

m_modules.find_all = find_all
m_modules.toggle_param = toggle_param
m_modules.update_param = update_param

return m_modules
