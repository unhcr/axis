module 'Problem Objective',
  setup: () ->
    Visio.manager = new Visio.Models.Manager()

test 'budget', () ->
  p = new Visio.Models.ProblemObjective(
    id: 'ben'
    name: 'lisa'
    aol_staff_budget: 10
    ol_staff_budget: 20
    aol_project_budget: 5
    ol_project_budget: 10
    aol_partner_budget: 30
    ol_partner_budget: 40
  )

  budget = p.budget()
  strictEqual budget, 115

  Visio.manager.get('scenerio_type')[Visio.Scenerios.OL] = false

  budget = p.budget()
  strictEqual budget, 45

  Visio.manager.get('budget_type')[Visio.Budgets.STAFF] = false
  budget = p.budget()
  strictEqual budget, 35
