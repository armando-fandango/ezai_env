import unittest

import torch

class TestTorch(unittest.TestCase):

    def test_torch_cuda_available(self):
        if torch.cuda.is_available():

            print('Torch Current GPU Device # and name:{} {}'.format(torch.cuda.current_device(),
                                                                  torch.cuda.get_device_name(torch.cuda.current_device())))
            print('# of GPU Devices:{}'.format(torch.cuda.device_count()))
        self.assertTrue(torch.cuda.is_available())

if __name__ == '__main__':
    unittest.main()