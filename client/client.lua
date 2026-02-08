CreateThread(function()
  while true do
    Wait(0)
    if NetworkIsSessionStarted() then
      TriggerServerEvent("Queue:playerActivated")
      return
    end
  end
end)