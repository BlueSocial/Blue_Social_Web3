// Code generated by mockery v2.42.2. DO NOT EDIT.

package mocks

import mock "github.com/stretchr/testify/mock"

// ReaperConfig is an autogenerated mock type for the ReaperChainConfig type
type ReaperConfig struct {
	mock.Mock
}

// FinalityDepth provides a mock function with given fields:
func (_m *ReaperConfig) FinalityDepth() uint32 {
	ret := _m.Called()

	if len(ret) == 0 {
		panic("no return value specified for FinalityDepth")
	}

	var r0 uint32
	if rf, ok := ret.Get(0).(func() uint32); ok {
		r0 = rf()
	} else {
		r0 = ret.Get(0).(uint32)
	}

	return r0
}

// NewReaperConfig creates a new instance of ReaperConfig. It also registers a testing interface on the mock and a cleanup function to assert the mocks expectations.
// The first argument is typically a *testing.T value.
func NewReaperConfig(t interface {
	mock.TestingT
	Cleanup(func())
}) *ReaperConfig {
	mock := &ReaperConfig{}
	mock.Mock.Test(t)

	t.Cleanup(func() { mock.AssertExpectations(t) })

	return mock
}
