defmodule Hatch do
  @moduledoc """
  Hatching new schemes with Eigr & Spawn.
  """
  alias SpawnSdk.System.SpawnSystem

  alias Hatch.Permitting.{
    RequirePermit,
    SubmitPermit,
    RejectPermit,
    ApprovePermit
  }

  alias Hatch.PermitActor

  def require_permit(params \\ %{}) do
    permit_id = Uniq.UUID.uuid4()
    params = Map.merge(params, %{permit_id: permit_id})

    with %RequirePermit{} = cmd <- RequirePermit.new(params),
         {:ok, _} <- SpawnSystem.spawn_actor("spawn-system", permit_id, PermitActor) do
      SpawnSystem.invoke("spawn-system", permit_id, :require, cmd)
    end
  end

  def submit_permit(permit_id) do
    with %SubmitPermit{} = cmd <- SubmitPermit.new(permit_id: permit_id) do
      SpawnSystem.invoke("spawn-system", permit_id, :submit, cmd)
    end
  end

  def reject_permit(permit_id, rejection_reason) do
    with %RejectPermit{} = cmd <-
           RejectPermit.new(permit_id: permit_id, rejection_reason: rejection_reason) do
      SpawnSystem.invoke("spawn-system", permit_id, :reject, cmd)
    end
  end

  def approve_permit(permit_id) do
    with %ApprovePermit{} = cmd <- ApprovePermit.new(permit_id: permit_id) do
      SpawnSystem.invoke("spawn-system", permit_id, :approve, cmd)
    end
  end
end
