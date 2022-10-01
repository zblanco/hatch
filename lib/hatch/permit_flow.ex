defmodule Hatch.PermitFlow do
  alias Hatch.Permitting.{
    Permit,
    RequirePermit
  }

  def init(%RequirePermit{} = cmd) do
    %Permit{
      permit_id: cmd.permit_id,
      notes: cmd.notes,
      authority: cmd.authority,
      status: "needs_submission",
      required_on: timestamp()
    }
  end

  def can_submit?(%Permit{status: "needs_submission", authority: authority})
      when not is_nil(authority) do
    :ok
  end

  def can_submit?(%Permit{status: "needs_submission"}) do
    {:error, "permit must be in a 'needs_submission` state to be submitted"}
  end

  def can_reject?(%Permit{status: "submitted"}) do
    :ok
  end

  def can_reject?(%Permit{status: "rejected"}) do
    {:error, "Already rejected!"}
  end

  def can_approve?(%Permit{status: "submitted"}) do
    :ok
  end

  def can_approve?(%Permit{status: _}) do
    {:error, "Must be submitted to be approved!"}
  end

  ## State Transitions

  def submit(%Permit{status: "needs_submission"} = permit) do
    %Permit{permit | status: "submitted", submitted_on: timestamp()}
  end

  def reject(%Permit{status: "submitted"} = permit, rejection_reason) do
    %Permit{
      permit
      | status: "rejected",
        rejected_on: timestamp(),
        rejection_reason: rejection_reason
    }
  end

  def approve(%Permit{status: "submitted"} = permit) do
    %Permit{permit | status: "submitted", approved_on: timestamp()}
  end

  defp timestamp(), do: DateTime.utc_now() |> DateTime.to_unix()
end
