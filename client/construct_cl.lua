
local consactivated = false
local curstruct = 1
local currotyaw = 0
local remove_obj = false

local numb_of_objs = 0

local shadows = {}

function OnKeyPress(key)
	if key == "Y" then
        consactivated=not consactivated
        if (consactivated==false) then
           CallRemoteEvent("RemoveShadow")
        end
    end
    if key == "E" then
        if (consactivated==true) then
           remove_obj=not remove_obj
           if remove_obj then
            CallRemoteEvent("RemoveShadow")
           end
        end
    end
    if key == "Mouse Wheel Up" then
        if (curstruct+1==numb_of_objs+1) then
            curstruct=1
        else
            curstruct=curstruct+1
        end    
    end
    if key == "Mouse Wheel Down" then
		if (curstruct-1==0) then
            curstruct=numb_of_objs
        else
            curstruct=curstruct-1
        end    
    end
    if key == "R" then
        if (currotyaw+90>180 ) then
           currotyaw=-90
        else
            currotyaw=currotyaw+90
        end
    end
    if key == "Left Mouse Button" then
        if consactivated then
            if (remove_obj==false) then
            CallRemoteEvent("Createcons")
            else
                local ScreenX, ScreenY = GetScreenSize()
                 SetMouseLocation(ScreenX/2, ScreenY/2)
                local entityType, entityId = GetMouseHitEntity()
                if (entityId~=0) then
                CallRemoteEvent("Removeobj",entityId)
                end
            end
        end
    end
end
AddEvent("OnKeyPress", OnKeyPress)
local lasthitposx = nil
local lasthitposy = nil
local lasthitposz = nil
local lastang = nil

local lastcons = nil

local lastconsactivated = nil
function tickhook(DeltaSeconds)
   if consactivated then
    local ScreenX, ScreenY = GetScreenSize()
    SetMouseLocation(ScreenX/2, ScreenY/2)
    if remove_obj==false then
    lastconsactivated=true
    local x,y,z = GetMouseHitLocation()
      if (x~=lasthitposx or y~=lasthitposy or z~=lasthitposz or lastang~=currotyaw or lastconsactivated~=consactivated or lastcons~=curstruct) then
          lasthitposx=x
          lasthitposy=y
          lasthitposz=z
          lastang=currotyaw
          lastcons=curstruct
          lastconsactivated=true
          if (x~=0) then 
            local entityType, entityId = GetMouseHitEntity()
            local pitch,yaw,roll = GetCameraRotation()
              CallRemoteEvent("UpdateCons",curstruct,currotyaw,x,y,z,entityId,yaw)
          else
            AddPlayerChat("Please look at valid locations")
          end
      end
    end
    else
        lastconsactivated=false
   end
end
AddEvent("OnGameTick", tickhook)

AddRemoteEvent("Createdobj",function(objid,collision)
    local delay = 50
    if (GetPing()~=0) then
        delay=GetPing()*6
    end
    Delay(delay,function()
    GetObjectActor(objid):SetActorEnableCollision(collision)
    SetObjectCastShadow(objid, collision)
    EnableObjectHitEvents(objid , collision)
    end)
end)

AddRemoteEvent("numberof_objects",function(number)
    numb_of_objs=number

end)

function render_cons()
    if consactivated then
    DrawText(5, 400, "Press Y to toggle construction")
    DrawText(5, 425, "Press E to toggle remove constructions")
    DrawText(5, 450, "Press R to rotate your construction")
    DrawText(5, 475, "Use the mouse wheel to change your object")
    DrawText(5, 500, "Use the left click to place your object")
    if remove_obj then
        local entityType, entityId = GetMouseHitEntity()
            if (entityId~=0) then
                local x, y, z = GetObjectLocation(entityId)
                local bResult, ScreenX, ScreenY = WorldToScreen(x, y, z)
                if bResult then
                    DrawText(ScreenX-40, ScreenY, "Left Click to remove")
                end
            end
    end
    end
end

AddEvent("OnRenderHUD", render_cons)