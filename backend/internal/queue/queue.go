package queue

import (
	"context"
	"log"
)

type Job struct {
	Name   string
	Action func() error
}

type Queue struct {
	name   string
	jobs   chan Job
	ctx    context.Context
	cancel context.CancelFunc
}

type JobQueues struct {
	Docker *Queue
}

func StartQueues() *JobQueues {
	return &JobQueues{
		Docker: initDockerQueue(),
	}
}

func (q *Queue) AddJob(job Job) {
	q.jobs <- job
	log.Printf("New job %s added to %s queue", job.Name, q.name)
}

func (q *Queue) DoWork() {
	for {
		select {
		case <-q.ctx.Done():
			log.Printf("Work done in queue %s: %s!", q.name, q.ctx.Err())
			return
		case job := <-q.jobs:
			err := job.Run()
			if err != nil {
				log.Print(err)
				continue
			}
		}
	}
}

// Run performs job execution.
func (j Job) Run() error {
	log.Printf("Job running: %s", j.Name)

	err := j.Action()
	if err != nil {
		return err
	}

	return nil
}

func initDockerQueue() *Queue {
	ctx, cancel := context.WithCancel(context.Background())

	return &Queue{
		name:   "Docker",
		jobs:   make(chan Job),
		ctx:    ctx,
		cancel: cancel,
	}
}
