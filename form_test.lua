local form = require('form')
-- 接口定义
local spec = {_tag = 'sepc'}
function spec:Show(msg)
	print(self._tag..':Show(msg) not implemented')
end
function spec:Dependence(target)
	print(self._tag..':Dependence(target) not implemented')
end
function spec:noImplementation()
	print(self._tag..':noImplementation() not implemented')
end
-- 接口实现
local port = form.build('spec', spec)
print('\nport ###test start---------------------------')
port:Show()
port:Dependence()
port:noImplementation()
function port:Show(msg)
	print('port:Show(msg)...')
	print(msg)
end
print('\noverwrite port:Show(msg)--------------------')
port:Show('port:Show using spec.Show')

function port:Dependence(target)
	print('port:Dependence(target)...')
	target.Show('DI, Dependence Input; implementation binded on '..target._tag..' from port')
end
print('\nport ###test over---------------------------')


-- 派生复用
local target
	= form.build('target'--[[, port]]) -- 可从#super 派生复用
		:spec(port)-- 可指定接口形式复用

print('\ntarget ###test start---------------------------')
target:noImplementation() -- spec:noImplementation()
target:Show('target:Show using port.Show') -- port:Show(msg)

print('\nDepend on [port] implement---------------------')
local tar_ = port:on(target)-- binding on target, implementation from port
tar_.Show('tar_.Show()')
print('\ntarget:Dependence(tar_) using port:Show(msg)---')
target:Dependence(tar_) -- port:Dependence(target)

print('\noverwrite target:Show(msg)---------------------')
function target:Show(msg)
	print('target:Show(msg)...')
	print(msg)
end
print('\ntarget:Dependence(tar_) using port:Show(msg)----')
target:Dependence(tar_)

print('\nDepend on [target] implement--------------------')
print('\ntarget:Dependence(tar_) using target:Show(msg)--')
tar_ = form.on(target, port)-- using target implementation spec from port
tar_.Show('tar_.Show()')
target:Dependence(tar_)
print('\ntarget ###test over-----------------------------')
